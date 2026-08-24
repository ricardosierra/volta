# GSD 03 — Testes

## Unit

| Arquivo | Cobre |
|---|---|
| `test_territory_grid.gd` | consultas, contagem incremental, seed/release de Claim, percentual, invariante de soma |
| `test_grid_space.gd` | conversões mundo↔célula, fronteiras, clamp |
| `test_arc_rasterizer.gd` | **propriedade de 4-conectividade (10 000 casos)** + 5 casos de mesa |
| `test_arc_tracker.gd` | ordem, comprimento, limpeza, auto-interseção, capacidade pré-alocada |
| `test_arc_overload.gd` | limite, taxa de decaimento, aviso, Seal após Overload |
| `test_seal_solver.gd` | **os 30 casos de mesa** listados em TERR-006 |
| `test_seal_applier.gd` | aplicação, roubo, contadores, sinais, ordem entre Seals no mesmo tick |
| `test_grid_serializer.gd` | round-trip binário + CRC32 |

## Integration

| Arquivo | Cobre |
|---|---|
| `test_draw_and_seal.gd` | ciclo completo: sair → desenhar → fechar → capturar |
| `test_seal_no_input_block.gd` | input continua sendo processado durante a captura |
| `test_steal_territory.gd` | roubo entre dois Runners com Claims adjacentes |
| `test_squeeze.gd` | Claim de um Runner zerado por captura |
| `test_territory_render_sync.gd` | textura renderizada corresponde ao grid |

## Gameplay (headless)

```bash
./tools/dev/simulate.sh 500 --mode classic --arena open_field --report .reports/gsd03.json
```

Invariantes por tick:

```text
[ ] Σ claim_count + neutras + bloqueadas == total de células
[ ] Runner em Safe tem arc_length == 0
[ ] todo Arc é 4-conectado
[ ] comprimento do Arc <= arc_max_cells
[ ] nenhum Runner fora do Field
[ ] nenhuma alocação de grid depois do setup
[ ] mesma seed → mesmo estado final
```

## Benchmarks (obrigatórios, em dispositivo real)

B01 `seal_small` · B02 `seal_medium` · B03 `seal_large` · B04 `seal_worst_case` ·
B05 `seal_concave` · B06 `seal_1000` · B07 `arc_marking` · B08 `collision_queries` ·
B11 `arena_large` · B12 `rapid_updates` · B13 `max_arc` · B14 `texture_update` ·
B15 `memory_stability`

(B09/B10, com bots, ficam para a GSD 05.)

## Manual

```text
[ ] capturar é satisfatório mesmo com arte provisória
[ ] a animação de preenchimento tem a direção certa (do fechamento para dentro)
[ ] o brilho do Arc cresce visivelmente com o comprimento
[ ] o aviso de Overload é perceptível antes de acontecer
[ ] o zoom da câmera acompanha sem enjoar
[ ] 60 FPS mantidos durante uma captura gigante
```

## Critério de saída

Tudo verde, incluindo os benchmarks **em dispositivo real** e as 500 partidas sem violação.
