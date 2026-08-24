# GSD 06 — Testes

## Unit

| Arquivo | Cobre |
|---|---|
| `test_score_service.gd` | cada termo da fórmula isolado; total; determinismo; score ≥ 0; tetos |
| `test_risk_multiplier.gd` | crescimento com o Arc; saturação no teto |
| `test_surge_service.gd` | subida, janelas, decaimento, zeragem por morte e Backwash, teto |
| `test_bonus_detector.gd` | 9 bônus × (dispara / não dispara) = 18 casos |
| `test_final_push.gd` | multiplicador só na janela; desabilitado por modo |
| `test_match_result.gd` | ranking, desempate em cascata, abandono |
| `test_local_leaderboard.gd` | ordenação, limite, persistência |

## Integration

| Arquivo | Cobre |
|---|---|
| `test_full_match_cycle.gd` | Countdown → Playing → fim → Results → nova partida |
| `test_restart_flow.gd` | PLAY AGAIN sem passar pelo menu; tempo < 0,8 s |
| `test_analytics_events.gd` | eventos e propriedades com adapter falso |
| `test_hud_updates.gd` | HUD reflete território, posição, tempo, risco e Surge |

## Gameplay (headless)

```bash
./tools/dev/simulate.sh 500 --mode classic --report .reports/gsd06.json
```

Invariantes adicionadas:

```text
[ ] score monotônico não decrescente durante a partida
[ ] toda partida produz um MatchResult válido
[ ] ranking sempre resolvido (nenhum empate sem desempate)
[ ] todo bônus nomeado é alcançável (cada um ocorre ao menos 1× em 500 partidas)
```

## Performance

```text
[ ] 60 FPS com 6 Runners no Mid, durante 3 min contínuos
[ ] Results → nova partida < 0,8 s
[ ] cálculo de score desprezível no profiler
[ ] nenhum hitch > 50 ms durante uma partida completa
```

## Manual / MVP

A checklist de 16 itens de `ACCEPTANCE.md`, executada em dispositivo real, mais o playtest com
3 pessoas de fora.

## Critério de saída

Tudo verde + checklist do MVP 16/16 + relatório de playtest escrito.
