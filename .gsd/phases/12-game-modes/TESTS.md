# GSD 12 — Testes

## Unit
`test_match_rules.gd` (carga, validação, campos obrigatórios por modo) ·
`test_time_bonus.gd` (fórmula, teto) · `test_wave_rule.gd` (composição por onda, velocidade
constante) · `test_domination_rule.gd` (meta, teto de tempo) · `test_reset_pulse.gd` (seleção
de células, aviso, nunca zera Claim) · `test_nemesis_targeting.gd`

## Integration
`test_mode_switch.gd` (trocar de modo sem recarregar) · uma partida completa headless por modo ·
`test_mode_leaderboards.gd`

## Gameplay (headless)
```bash
for m in classic time_attack survival domination endless; do
  ./tools/dev/simulate.sh 500 --mode $m --report .reports/gsd12-$m.json
done
```
Invariantes: nenhuma partida infinita · duração dentro da janela · Reset Pulse nunca causa
Squeeze · Survival nunca aumenta velocidade.

## Manual
```text
[ ] cada modo responde "o que ele faz que o Classic não faz?"
[ ] Survival: dá para perceber o que mudou a cada onda
[ ] Domination: as barras dos adversários criam tensão
[ ] Endless: 30 min sem degradação
[ ] Time Attack: ganhar tempo é sentido, não só lido
```
