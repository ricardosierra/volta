# Phase 2: Core Movement - Context

**Gathered:** 2026-08-24 · **Reaberta:** 2026-09-02 (ver `<reexecution>`)
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

O Runner navega pela arena com controle que responde — latência abaixo de 50 ms, simulação determinística a 60 Hz e câmera que ninguém percebe

**Requisitos cobertos:** MOV-01, MOV-02, MOV-03, MOV-04, MOV-05, MOV-06, MOV-07

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- Grid, Claim, Arc, Seal (é 03)
- Colisão, morte, respawn (é 04)
- Bots (é 05)
- Arte e UI de verdade (é 07/08)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/02-core-movement/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Modelo de movimento
- Ângulo livre com taxa máxima de giro (ADR-0006). Não é grid-locked, não é 8 direções.
- Velocidade e taxa de giro vêm de `RunnerBalance` — nenhum literal no código.
- O Runner **mantém** a direção ao soltar o dedo (configurável, padrão ligado).

### Tick e interpolação
- Simulação em `_physics_process` a 60 Hz fixo, ordem fixa: input → IA → movimento → grid → seals → regras → eventos.
- Um único componente `InterpolatedVisual` guarda `prev`/`curr` e interpola em `_process`. Ninguém implementa interpolação duas vezes.
- Proibido `await` e proibido depender de `delta` variável dentro da simulação.

### Input
- `InputDriver.poll(delta) -> Vector2` é a única saída; nenhum `InputEvent` chega ao Runner.
- Zona morta do swipe em **milímetros físicos**, convertida pelo DPI da tela — não em pixels.
- Buffer de input: comando que chega durante uma virada entra na fila, não substitui; descarte por idade.
- Toque que começa sobre UI não vira movimento.

### Câmera
- Follow com suavização exponencial + lookahead, atualizada sobre a posição **interpolada**.
- API pronta para zoom dinâmico (fase 3) e punches (fase 9), mas sem implementá-los agora.

### FSM
- Transições declaradas na construção da máquina; transição inválida dá assert em debug e log em release.
- Nesta fase o Runner só precisa de `Spawn`, `Safe` e `Eliminated`.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/02-core-movement/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<reexecution>
## Re-execução após auditoria (2026-09-02)

**Por que esta fase está aberta de novo.** Foi marcada concluída em 2026-08-25 com base num
`02-VERIFICATION.md` de três linhas, sem teste por trás. A auditoria de alcançabilidade de
2026-08-31 (`.planning/audit/README.md`, seção da auditoria em `.planning/STATE.md`) reabriu as
fases 2–25. Os cinco planos antigos (greenfield, 2026-08-24) e o VERIFICATION fabricado foram
removidos em 2026-09-02 (commit `dbca7cf`). Este bloco + os documentos canônicos são o ponto de
partida do replanejamento. **Tudo acima neste arquivo continua valendo** (decisões, escopo).

**Estado real do código em 2026-09-02** — teste de alcançabilidade: referências fora do próprio
arquivo em `apps/mobile/src`, `scenes`, `tests`, `tools`. "0 refs" = ninguém instancia, chama
ou escuta.

| Tarefa (TASKS.md) | Classe(s) e arquivo | Situação verificada |
|---|---|---|
| MOVE-001 FSM | `StateMachine`, `State` (`src/core/fsm/`), `GameState` + `src/gameplay/states/*_state.gd` | existem; `MatchDirector._ready()` cria `GameState` e `setup_match()` avança BOOT→MENU→LOADING→COUNTDOWN; **nenhum teste** cobre a tabela de transições, rejeição de transição inválida ou o congelamento de `Paused` |
| MOVE-002 tick fixo | `SimulationClock` (`src/gameplay/simulation_clock.gd`, 16 linhas), `MatchDirector._physics_process` | `MatchDirector.step()` só faz `clock.advance()`; as etapas input→movimento→… estão **só como comentário**; a simulação não move Runner nenhum; `_physics_process` recebe `delta` variável e não há teste headless de determinismo |
| MOVE-003 Runner | `Runner` (20 linhas), `RunnerState`, `Movement`, `StatBlock` (`src/runner/`) | existem; `Runner.tick(delta)` chama `Movement.step(state, stats, delta)`, mas **`MatchDirector.step()` nunca chama `Runner.tick()`**; `src/runner/states/safe_state.gd` tem 0 refs; conferir se `Movement` lê `RunnerBalance` (`.tres`) ou literal |
| MOVE-004 interpolação | `InterpolatedVisual` (29 linhas), `RunnerView` (22 linhas), `RunnerViewSpawner` (`src/presentation/`) | `RunnerViewSpawner` é ligado por `root.gd` (fase 26.1) e cria uma `RunnerView` por `runner_spawned`; mas `RunnerView` **não usa `InterpolatedVisual`** e recebe `position` uma única vez no spawn — nunca acompanha a simulação. `InterpolatedVisual` só é citado por `GameCamera` |
| MOVE-005 InputRouter + swipe | `InputRouter` (`src/input/input_router.gd`, `poll_direction(delta)`), `InputDriver`, `SwipeDriver` | **`InputRouter` tem 0 refs** — ninguém o instancia nem faz `poll_direction()`; `SwipeDriver` só é criado pelo próprio router e por `settings_controls.gd` |
| MOVE-006 buffer | `InputBuffer` (`src/input/input_buffer.gd`) | **0 refs** |
| MOVE-007 joystick/relativo | `JoystickDriver`, `RelativeDriver` (`src/input/drivers/`) | só em `settings_controls.gd`, tela que nenhuma outra empilha |
| MOVE-008 arena | `ArenaDefinition`, `Arena` (`src/arena/`) | reais e usadas por `ai/bot_safety.gd`, `ai/bot_steering.gd` e `GameCamera` (auditoria da fase 13 confirmou) |
| MOVE-009 câmera | `GameCamera`, `CameraReactions` (`src/presentation/camera/`) | **0 refs**; `MatchDirector.setup_match()` cria um `Camera2D` cru em `(540, 960)` — dentro de `gameplay/`, que não deveria conhecer câmera |
| MOVE-010 latência | `apps/mobile/tools/dev/latency_test.gd` | existe, nunca rodado num aparelho; `docs/performance/device-results.md` traz números sem origem (fase 19, auditoria) — reescrever com medição real ou `_pendente_` |

**O que de fato roda quando o jogador toca PLAY hoje.** `root.gd` empilha `MatchScreen`
(`src/ui/screens/match_screen.gd`, 588 linhas) e cria `MatchDirector` + `RunnerViewSpawner`.
A partida visível é um **loop próprio dentro da UI**: `_update_player`, `_update_bots`,
`_resolve_combat`, `_seal_trail`, `_read_direction` e `_input(event)` lendo `InputEvent`
direto, com `const PLAYER_SPEED = 340.0` e `const BOT_SPEED = 205.0` no código, tudo em
`_process(delta)` variável. A simulação de `gameplay/`, `runner/` e `input/` não move nada. Isso
viola ADR-0014 (tick fixo), "nenhum número de gameplay no código" e "nenhum `InputEvent` chega ao
Runner". As `RunnerView`s criadas pelo spawner ficam paradas no ponto de spawn enquanto a tela
desenha círculos próprios via `MatchFieldRenderer`.

**Entregável desta re-execução** — os mesmos MOVE-001..010 de `TASKS.md`, com a prova invertida:
cada item precisa ser **alcançável a partir do jogo em execução** (`scenes/main.tscn` →
`root.gd` → `MatchDirector`), não apenas existir em disco. Concretamente:

- `MatchDirector.step()` executa input → movimento a 60 Hz fixo sobre `Runner`s reais, com
  velocidade e taxa de giro vindas de `RunnerBalance` (`.tres`) — zero literal de gameplay.
- O Runner do jogador recebe direção **somente** de `InputRouter` (`poll_direction`), com
  `InputBuffer` no caminho; os três drivers trocáveis em runtime.
- `RunnerView` passa a ler `prev/curr` via `InterpolatedVisual` (ou a estender), atualizada
  pela simulação a cada tick; `GameCamera` segue a posição interpolada; o `Camera2D` cru sai de
  `gameplay/`.
- `MatchScreen` deixa de simular: o loop `_update_player/_update_bots/_resolve_combat/_seal_trail`
  e as constantes de velocidade saem. O que é território/combate (fases 3 e 4) **não** é
  reimplementado aqui — a tela mostra o que a simulação da fase 2 entrega (runners se movendo na
  arena com o HUD provisório) e as fases 3/4 religam trilha, captura e colisão. O que a tela
  perde temporariamente vai para `.gsd/BACKLOG.md` com a fase de destino.
- `Paused` congela posição, contadores e timers — provado por teste de integração.
- Os testes de `TESTS.md` existem e passam: os 7 unit + 3 integration listados lá, mais um
  teste de alcançabilidade que sobe `MatchDirector` do mesmo jeito que `root.gd` e prova que o
  Runner do jogador se move em resposta ao `InputRouter` (não a `InputEvent`).
- `SUMMARY.md` e `VERIFICATION.md` escritos a partir da saída real de `./tools/ci/test-client.sh`,
  `./tools/ci/validate-repo.sh` e `./tools/ci/lint.sh` — colada, nunca de memória.

**Não fazer:** apagar código que funciona; reescrever o que só precisa ser ligado; puxar
Seal/colisão/bots (fases 3/4/5) para cá; inventar medição de dispositivo. A02-02, A02-04, A02-12
e o teste de sensação (`ACCEPTANCE.md`) dependem de aparelho físico e de pessoas — ficam
explicitamente `human_needed` no VERIFICATION, nunca "passed".

**Ferramental (aprendido nas fases 1, 26 e 26.1 — vale para planner e todo executor):**
- `gsd-tools state begin-phase` e `state advance-plan` **corrompem** `STATE.md` neste repo;
  `state update-progress`, `roadmap update-plan-progress` e `requirements mark-complete` são
  no-op silencioso. Não rodar; editar `STATE.md`, `ROADMAP.md` e `REQUIREMENTS.md` à mão.
- Executores paralelos compartilham o índice git: commitar **sempre** com pathspec —
  `git commit -m "msg" -- <caminho> [<caminho>]`. Proibido `git add -A`, `git add .`,
  `git commit -a` e `git commit` sem pathspec. Repetir em caso de `index.lock`.
- Engine real: Godot 4.7.2 em `$HOME/.local/share/godot-bin/godot` (CLAUDE.md ainda cita 4.3).
- Baseline em 2026-09-02: `test-client.sh` 50/50 testes verdes em 18 scripts;
  `validate-repo.sh` verde desde a fase 26.1. Regressão em qualquer um bloqueia o plano.
- Branch da fase: `feature/gsd-02-core-movement` (criada de `master` em 2026-09-02).

</reexecution>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/02-core-movement/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/02-core-movement/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/02-core-movement/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/02-core-movement/TESTS.md` — os testes que precisam existir
- `.gsd/phases/02-core-movement/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/02-core-movement/`
- `docs/gameplay/controls.md`
- `docs/architecture/state-machines.md`
- `docs/decisions/ADR-0006-movement-model.md`
- `docs/decisions/ADR-0014-simulation-tick-model.md`
- `docs/design/balance.md` §2 e §11

### Regras que valem em toda fase
- `CLAUDE.md` — as 10 regras de código verificadas por máquina
- `docs/architecture/overview.md` — camadas, convenções, o que não fazer
- `docs/design/balance.md` — **o único lugar com números de gameplay**
- `.gsd/QUALITY_GATES.md` — o que precisa ser verdade para a fase fechar

</canonical_refs>

<code_context>
## Existing Code Insights

### Padrões estabelecidos
- Simulação (`territory/`, `runner/`, `ai/`, `gameplay/`) **não importa** `presentation/` nem `ui/` — verificado pelo CI.
- Toda dependência externa entra por interface (`*Repository`, `*Service`), com implementação `Local*` antes de `Remote*`.
- Nenhum número de gameplay no código: tudo em `.tres` sob `packages/shared/config/`.
- Nenhum arquivo-depósito (`utils.gd`, `manager.gd`, `global.gd`…) — o CI reprova pelo nome.

### Verificação antes de fechar qualquer tarefa
```bash
./tools/ci/validate-repo.sh
./tools/ci/lint.sh
./tools/ci/test-client.sh
```

</code_context>

<deferred>
## Deferred Ideas

Tudo que estiver fora do escopo declarado acima vai para `.gsd/BACKLOG.md` com uma linha —
nunca para o código desta fase. O backlog já contém 18 itens deliberadamente adiados,
7 placeholders e 5 mocks, todos com fase de destino.

</deferred>

---

*Phase: 02-core-movement*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
