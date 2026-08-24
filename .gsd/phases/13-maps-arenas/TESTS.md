# GSD 13 — Testes

## Unit
`test_arena_definition.gd` (validação, região isolada rejeitada) ·
`test_blocked_cells.gd` (não capturadas, fora do percentual) ·
`test_seal_with_obstacles.gd` (5 casos de mesa novos, incluindo buraco central grande) ·
`test_hazard_zone.gd` (morte no `Rift`, causa registrada)

## Gameplay
500 partidas por arena (2 000+ no total). Invariantes: 0 bot travado · percentual correto com
bloqueios · nenhuma partida infinita · morte por perigo só onde a arena declara.

## Benchmarks
Seal por arena, com destaque para `Halo` (topologia adversa) e `Archipelago` (muitas regiões).

## Manual
```text
[ ] cada arena muda a estratégia de forma perceptível
[ ] a fenda do Rift é impossível de não ver
[ ] nenhum canto permite defesa infinita
[ ] dá para reconhecer a arena num relance
```
