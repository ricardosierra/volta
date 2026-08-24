# GSD 04 — Testes

## Unit

| Arquivo | Cobre |
|---|---|
| `test_collision_resolver.gd` | detecção de Arc inimigo, Arc próprio, célula neutra; travessia de várias células no mesmo tick |
| `test_backwash.gd` | Arc apagado e reiniciado, penalidade aplicada e expirada, **vulnerabilidade mantida**, não empilha |
| `test_elimination.gd` | Break, crédito, morte mútua, dois agressores no mesmo tick |
| `test_spawner.gd` | local válido, distância mínima, mapa lotado, 1 000 respawns |
| `test_tick_order.gd` | Seal antes de morte; dois Seals por `runner_id`; determinismo |

## Integration

| Arquivo | Cobre |
|---|---|
| `test_break_flow.gd` | cortar Arc → morte → território neutro → respawn → jogável |
| `test_squeeze_flow.gd` | cercar o Claim inteiro de um inimigo → eliminação |
| `test_border_backwash.gd` | borda enquanto desenha vs borda em `Safe` |
| `test_invuln.gd` | invulnerabilidade no spawn e queda ao sair do Claim |

## Gameplay (headless)

```bash
./tools/dev/simulate.sh 500 --bots 4 --report .reports/gsd04.json
```

Invariantes adicionadas nesta fase:

```text
[ ] nenhum Runner morto possui células de Claim
[ ] nenhum Runner permanece em Hit por mais de 1 tick
[ ] nenhum Arc pertence a Runner morto
[ ] soma de Breaks creditados == número de mortes por corte de Arc
[ ] nenhuma morte por causa fora da lista fechada
```

Métricas coletadas (baseline para balanceamento):
mortes por causa · Backwash por partida por Runner · mortes nos primeiros 15 s ·
tempo médio de vida.

## Manual

```text
[ ] cortar o arco de alguém é satisfatório mesmo sem VFX final
[ ] morrer é informativo: dá para ver quem cortou e onde
[ ] Backwash é claramente diferente de morte (cor, texto, som provisório)
[ ] a seta de ameaça aparece a tempo de reagir
[ ] respawn é rápido o suficiente para não frustrar
```

## Critério de saída

Todos verdes + teste de sensação com ≥ 90 % de mortes explicadas corretamente.
