# Arquitetura do cliente

> Uma regra acima de todas: **a simulação não conhece a apresentação**. Você deve conseguir
> rodar uma partida inteira, com bots, sem instanciar um único nó visual. Isso é o que torna
> possível: testes headless, stress test de 500 partidas, replay determinístico e, mais tarde,
> um servidor autoritativo que reutiliza o mesmo código.

---

## 1. Camadas

```text
┌──────────────────────────────────────────────────────────────┐
│  ui/            Telas, HUD, navegação, design system         │
│  presentation/  Câmera, VFX, áudio, háptico, juice           │  ← só LÊ a simulação
├──────────────────────────────────────────────────────────────┤
│  gameplay/      MatchDirector, regras de modo, score, FSM    │
│  territory/     Grid, Claim, Arc, SealSolver                 │  ← simulação pura
│  runner/        Runner, movimento, colisão, estados          │     (sem Node visual)
│  ai/            BotBrain, utilidade, percepção               │
│  arena/         Definição de arena, spawn, modificadores     │
├──────────────────────────────────────────────────────────────┤
│  input/         Drivers de input → direção desejada          │
│  progression/   Perfil, XP, conquistas, desafios, cosméticos │
│  platform/      Analytics, telemetria, remote config, store  │
│  core/          Bootstrap, EventBus, Config, Log, Save, DI   │
└──────────────────────────────────────────────────────────────┘
```

**Regra de dependência:** uma camada só pode depender de camadas **abaixo** dela.
`territory/` nunca importa `presentation/`. `core/` não importa ninguém.
Violação é erro de CI (`tools/ci/check_layering.gd`).

---

## 2. Módulos e responsabilidades

| Módulo | Responsável por | NÃO é responsável por |
|---|---|---|
| `core/bootstrap` | ordem de inicialização, splash, primeira cena | lógica de jogo |
| `core/event_bus` | eventos globais **de baixa frequência** (partida iniciou, item desbloqueado) | eventos por frame |
| `core/config` | carregar `Resource` de configuração e balance | decidir regras |
| `core/save` | persistir, versionar, migrar | saber o que os dados significam |
| `core/log` | logging estruturado por categoria | formatar UI |
| `gameplay/match_director` | criar a partida, tick da simulação, condições de fim | desenhar |
| `gameplay/score` | aplicar a fórmula, Surge, bônus | mostrar número |
| `territory/grid` | dono por célula, arcos, consultas | quem pode capturar |
| `territory/seal_solver` | flood fill, região fechada, aplicação | animação |
| `runner/runner` | estado, posição, direção, colisão | input |
| `ai/bot_brain` | decidir a direção desejada | mover |
| `arena/arena_definition` | células bloqueadas, spawns, modificadores | renderizar fundo |
| `input/input_router` | escolher driver, entregar direção | filtrar por estado de jogo |
| `presentation/*` | tudo que se vê e se ouve | mudar estado de simulação |
| `progression/*` | perfil e desbloqueios | economia de loja (isso é `store`) |
| `platform/*` | falar com o mundo externo por interface | conhecer regras |

---

## 3. Comunicação

Três mecanismos, com uso definido — usar o errado é rejeitado em review:

| Mecanismo | Quando usar | Exemplo |
|---|---|---|
| **Chamada direta** | dependência descendente explícita | `match_director` chama `seal_solver.solve()` |
| **Signal** | notificação local, um emissor, poucos ouvintes | `runner.state_changed` |
| **EventBus** | evento global, muitos ouvintes desacoplados, **baixa frequência** | `match_started`, `achievement_unlocked` |

Proibido: EventBus por frame; EventBus para passar dado que já existe numa referência direta;
sinal que atravessa três camadas para "evitar acoplamento" (isso é acoplamento pior, escondido).

---

## 4. Injeção de dependência

Sem service locator global mágico. `core/bootstrap` monta o grafo e injeta:

```gdscript
var services := ServiceRegistry.new()
services.register("save", FileSaveService.new(...))
services.register("analytics", NoopAnalytics.new())
services.register("leaderboard", LocalLeaderboardRepository.new(...))
```

Cada consumidor recebe o que precisa **no construtor ou em `setup()`**, tipado por interface.
Nada de `Global.save.data.player.coins` espalhado pelo projeto.

---

## 5. Convenções de código

- Arquivos `snake_case.gd`, `class_name` em PascalCase, **um tipo por arquivo**.
- **Tipagem estática obrigatória**: parâmetros, retorno e membros. `Variant` só com comentário.
- Ordem no arquivo: `class_name` → `extends` → docstring → `signal` → `enum` → `const` →
  `@export` → vars → `_ready` → públicos → privados (`_prefixo`).
- Privado é `_prefixo`. Nada de "privado por convenção verbal".
- Sem `get_node()` espalhado: `@onready` no topo ou injeção.
- **Proibidos:** `Utils.gd`, `Helpers.gd`, `Manager.gd`, `Global.gd`, `Misc.gd`, `Common.gd`.
  Nomes de arquivo são checados pelo CI.
- Arquivo acima de 400 linhas exige justificativa no PR; acima de 600 é bloqueio.
- Função acima de 50 linhas: idem.
- Nenhum literal numérico de gameplay fora de `Resource` de config.
- `TODO` sem `(GSD-XX/TASK-YYY)` quebra o CI.

---

## 6. Alocação e pooling

Nada de `new()` por frame no caminho quente:

| Objeto | Estratégia |
|---|---|
| Células do grid | `PackedByteArray` pré-alocado, reutilizado a partida inteira |
| Buffers de flood fill | pré-alocados no `SealSolver`, reutilizados entre Seals |
| Partículas | pool por tipo, tamanho definido no preset de qualidade |
| Popups de bônus | pool de 8 |
| Runners | pool do tamanho máximo do modo |
| Segmentos de Arc (visual) | `MultiMesh` ou desenho imediato — nunca um `Node2D` por célula |

---

## 7. Tick

Simulação a **60 Hz fixo** em `_physics_process`; render livre (60/90/120 Hz) com interpolação
manual dos visuais. Ver [`../decisions/ADR-0014`](../decisions/ADR-0014-simulation-tick-model.md).

```text
_physics_process(1/60):  input → IA (2 bots/tick) → movimento → grid → seals → regras → eventos
_process(delta):         interpola visuais, atualiza VFX, HUD, câmera
```

---

## 8. Estrutura de pastas do cliente

```text
apps/mobile/
├── project.godot
├── src/
│   ├── core/         bootstrap, event_bus, config, log, save, registry, build
│   ├── gameplay/     match_director, game_state, modes/, score/, rules/
│   ├── territory/    grid.gd, claim_map.gd, arc_tracker.gd, seal_solver.gd
│   ├── runner/       runner.gd, runner_state.gd, movement.gd, stat_block.gd
│   ├── ai/           bot_brain.gd, actions/, perception/, profiles/
│   ├── arena/        arena_definition.gd, spawner.gd, modifiers/
│   ├── input/        input_router.gd, drivers/
│   ├── presentation/ camera/, vfx/, audio/, haptics/, territory_renderer.gd
│   ├── ui/           screens/, hud/, design_system/, components/
│   ├── progression/  profile.gd, xp.gd, achievements/, challenges/, cosmetics/
│   └── platform/     analytics/, telemetry/, remote_config/, store/
├── scenes/           .tscn organizados espelhando src/
├── resources/        .tres de balance, temas, modos, perfis de bot
├── assets/           importados (arte/áudio já processados)
└── tests/            unit/, integration/, gameplay/  (GUT)
```

---

## 9. O que NÃO fazemos

- ❌ Um `GameManager` autoload com metade do jogo dentro.
- ❌ Herança profunda de nós (`Entity → Character → Player → HumanPlayer`). Composição.
- ❌ Lógica em `_process` que deveria estar em `_physics_process`.
- ❌ `await` em caminho de simulação (torna o tick não determinístico).
- ❌ Acesso a `Engine.get_singleton()` de SDK dentro de gameplay.
- ❌ Estado de partida guardado em nó de UI.
