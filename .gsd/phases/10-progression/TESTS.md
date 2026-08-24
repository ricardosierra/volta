# GSD 10 — Testes

## Unit
`test_xp_service.gd` · `test_rank_curve.gd` · `test_stats_service.gd` (incl. divisão por zero) ·
`test_achievements.gd` (cada tipo de condição, progresso, desbloqueio único) ·
`test_challenge_generation.gd` (seed diária, sem repetição, expiração, fuso) ·
`test_wallet.gd` (teto, saldo não negativo, histórico) · `test_profile_repository.gd`

## Integration
`test_match_to_progression.gd` (MatchResult → XP, stats, conquistas, desafios, carteira) ·
`test_progress_persistence.gd` (kill do app em 5 momentos diferentes) ·
`test_results_cascade.gd` (ordem, pulável, salva ao fim)

## Simulação
`economy_sim` com 3 perfis × 30 dias; métricas comparadas com `docs/design/economy.md`.

## Manual
```text
[ ] subir de nível é comemorado
[ ] desafio do dia é visível em um toque do menu
[ ] progresso parcial de conquista aparece
[ ] resultado é recompensador, não só informativo
[ ] nada de progressão dá vantagem
```
