# GSD 14 — Testes

## Unit
`test_stat_block_powerups.gd` (empilhar, substituir, expirar, 1 000 ciclos) ·
um arquivo por power-up, cobrindo aplicação, expiração e **o contra-jogo específico** ·
`test_powerup_spawner.gd` (intervalo, máximo, distância mínima, determinismo)

## Integration
`test_powerup_pickup.gd` · `test_powerup_replacement.gd` · `test_bot_powerup.gd` ·
`test_powerup_no_territory_effect.gd` (nenhum altera área capturada)

## Gameplay
2 000 partidas com power-ups ligados. Métricas de saúde de `docs/gameplay/power-ups.md`.

## Manual
```text
[ ] dá para saber o que o adversário pegou olhando para ele
[ ] cada power-up tem contra-jogo executável
[ ] nenhum efeito esconde informação
[ ] o indicador de HUD não polui
```

## Gate da Alpha
Checklist completo de `ACCEPTANCE.md`, com playtest de 5 pessoas.
