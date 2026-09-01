# Auditoria das Fases 11 a 14

**Data:** 2026-08-31
**Método:** teste de alcançabilidade — para cada classe entregue, verificar se algo fora do
próprio arquivo a referencia, se é registrada em `apps/mobile/src/core/bootstrap.gd`, se está
em `[autoload]` de `apps/mobile/project.godot`, ou se é citada por uma cena.

**Fatos de base confirmados:** `bootstrap.gd` registra exatamente 6 serviços (`quality`,
`haptics`, `vfx`, `wallet`, `catalog`, `profile_repo`); só existem dois autoloads (`Bootstrap`,
`Log`); o sinal `match_ended` (`match_director.gd:126`) não tem nenhum ouvinte conectado.

## Veredito

| Fase | Artefatos conferidos | Alcançável no jogo? | Implementação | Veredito |
|---|---|---|---|---|
| 11 — Cosmetics | Catalog, CosmeticItem, Inventory, Loadout, UnlockService, SkinsScreen | Parcial | Dados reais, telas em `pass` | **Parcial** |
| 12 — Game Modes | MatchRules, TimeBonusRule, WaveRule, ResetPulseRule | **Não** | Escrita, nunca ligada | **Não confiável** |
| 13 — Maps & Arenas | Arena, ArenaDefinition, definições de arena | **Sim** | Real e usada | **Confiável** |
| 14 — Power-ups | PowerUpService, PowerUpSpawner, PowerUpEffect, BulwarkEffect, OverdriveEffect | **Não** | Escrita, nunca ligada | **Não confiável** |

## Fase 11 — Cosmetics (Parcial)

O que é real: `Catalog` está registrado em `bootstrap.gd:54` e `CosmeticItem` é usado em 4
lugares. O catálogo como dado existe.

O que não é:

- `apps/mobile/src/ui/screens/skins_screen.gd` é um stub `pass` puro. As duas funções
  (`on_pushed`, `_on_item_pressed`) têm corpo `pass` com comentários descrevendo a intenção.
- `UnlockService` tem **zero** referências em código. A única ocorrência do nome no repositório
  está **dentro de um comentário** (`skins_screen.gd:12`: `# If not owned -> Attempt purchase
  via UnlockService`). Não há compra, não há desbloqueio.
- `Inventory` é referenciado apenas por `unlock_service.gd:5` — que é morto. Morto por
  transitividade.
- `Loadout` é referenciado por `presentation/runner_view.gd`, mas `RunnerView.apply_cosmetics()`
  **nunca é chamado**: `match_director.gd:56-58` instancia a view e define só a posição, com o
  comentário `# If catalog/loadout are available via Autoload, we would apply cosmetics here`.
  Nenhum cosmético é aplicado em partida.

**Conclusão:** o catálogo existe como dado; a economia (comprar, desbloquear, equipar, exibir)
não existe.

## Fase 12 — Additional Game Modes (Não confiável)

`MatchRules`, `TimeBonusRule`, `WaveRule` e `ResetPulseRule` têm **zero** referências fora dos
próprios arquivos. Nada em `match_director.gd` injeta um conjunto de regras, e `bootstrap.gd`
não registra nenhum deles.

Os quatro modos prometidos (Time Attack, Survival, Domination, Endless) não são selecionáveis
nem alcançáveis. Só o fluxo Classic roda, e roda sem passar por `MatchRules`.

## Fase 13 — Maps & Arena Variations (Confiável)

Única das quatro que se sustenta. `ArenaDefinition` é consumida por código vivo da simulação:

- `apps/mobile/src/ai/bot_safety.gd:4` — `evaluate_risk(pos, arena: ArenaDefinition)`
- `apps/mobile/src/ai/bot_steering.gd:4` — `get_desired_velocity(..., arena: ArenaDefinition)`
- `apps/mobile/src/arena/arena.gd:4` — `var definition: ArenaDefinition`
- `apps/mobile/src/presentation/camera/game_camera.gd:8` — `var arena: Arena`

A abstração de arena está de fato integrada à IA e à câmera. Ressalva não verificada nesta
auditoria: se as quatro arenas novas (Archipelago, Rift, Crossroads, Halo) são realmente
selecionáveis pelo jogador, já que a seleção passaria pela UI de modos da Fase 12, que não
existe.

## Fase 14 — Power-ups (Não confiável)

A fase que a ROADMAP diz ter **fechado o marco Alpha**. Todo o subsistema é ilha:

- `PowerUpService` — 0 referências externas, não registrado em `bootstrap.gd`
- `PowerUpSpawner` — 0 referências externas
- `BulwarkEffect`, `OverdriveEffect` — 0 referências externas
- `PowerUpEffect` — referenciado apenas pelos dois efeitos acima e pelo próprio
  `power_up_service.gd`, todos mortos

Além disso, dos 6 power-ups prometidos com contra-jogo, existem 2 efeitos concretos no
repositório. Nenhum power-up pode aparecer em partida.

## O que precisaria para religar

| Fase | Religação mínima |
|---|---|
| 11 | Registrar `UnlockService`/`Inventory` em `bootstrap.gd`; implementar `skins_screen.gd`; chamar `RunnerView.apply_cosmetics(loadout, catalog)` a partir da camada de apresentação |
| 12 | Injetar `MatchRules` em `MatchDirector`; expor seleção de modo na UI; ligar as regras ao ciclo de partida |
| 13 | Nada estrutural — confirmar apenas que as 4 arenas são selecionáveis quando a Fase 12 for religada |
| 14 | Registrar `PowerUpService` e `PowerUpSpawner`; ligá-los ao tick da simulação e à colisão; implementar os 4 efeitos faltantes |

## Impacto nas Fases 27-38

- **Fase 29 (Conquistas)** depende de eventos de progressão que hoje não disparam.
- **Fase 30 (Game Stats)** pretende reportar estatísticas de modos e power-ups que nunca ocorrem.
- **Fase 31 (Quests/Rewards)** desenha missões sobre modos inalcançáveis.
- **Fase 13 é a única base sólida** entre as quatro: mapas podem ser usados como dimensão real
  de conquista e estatística.

---

*Auditoria feita diretamente pelo orquestrador (sem subagente), somente leitura.*
