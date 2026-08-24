# GSD 14 — Critérios de aceite 🏁 ALPHA

## Da fase

| # | Critério | Como verificar |
|---|---|---|
| A14-01 | Os 6 power-ups funcionam conforme a especificação | testes |
| A14-02 | Nenhum mata por si só | revisão + teste |
| A14-03 | Todo efeito é reversível e idempotente | teste de 1 000 ciclos |
| A14-04 | `Overdrive` não muda a taxa de giro | teste |
| A14-05 | `Arc Guard` deixa a ponta vulnerável | teste |
| A14-06 | `Amplify` não altera área | teste |
| A14-07 | `Bulwark` não protege contra Squeeze | teste |
| A14-08 | `Drag Field` afeta o dono | teste |
| A14-09 | Orbe nunca nasce perto de um Runner e sempre avisa | teste |
| A14-10 | Bots coletam e reagem | stress |
| A14-11 | < 15 % de partidas decididas por power-up | 2 000 partidas |
| A14-12 | Winrate do primeiro orbe em 50 % ± 8 pp | 2 000 partidas |
| A14-13 | Os 7 canais de game feel marcados para cada power-up | auditoria |

## Gate da Alpha

```text
[ ] tudo do MVP continua verdadeiro
[ ] progressão completa (XP, ranks, conquistas, desafios)
[ ] cosméticos (skins, arcos, temas, efeitos de Seal)
[ ] áudio completo (SFX + música adaptativa)
[ ] VFX completo
[ ] háptico completo
[ ] 5 arenas
[ ] 5 modos
[ ] save confiável com migração testada
[ ] analytics emitindo (mesmo com adapter Noop)
[ ] performance validada em Low, Mid e High
[ ] ZERO placeholder de arte
[ ] ZERO mock além dos com destino registrado
[ ] playtest: >= 80 % dos novos fazem o 1o Seal em < 25 s
[ ] playtest: >= 4/5 dizem que "parece um jogo publicado"
```

O gate da Alpha é executado por inteiro nesta fase e registrado em
`.gsd/QUALITY_GATES.md` e em `.gsd/STATUS.md`.
