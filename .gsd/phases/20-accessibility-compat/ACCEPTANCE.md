# GSD 20 — Critérios de aceite 🏁 BETA

## Da fase

| # | Critério | Como verificar |
|---|---|---|
| A20-01 | Matriz de dispositivos executada e registrada | `device-results.md` |
| A20-02 | Safe area correta em toda a matriz | capturas |
| A20-03 | Tablet com layout adaptado | dispositivo |
| A20-04 | Low-end a 60 FPS | dispositivo |
| A20-05 | 60/90/120 Hz e LTPO sem mudança de comportamento | dispositivo |
| A20-06 | 3 temas de daltonismo + alto contraste, validados | simulador + teste cego |
| A20-07 | Escala de UI 1,25 sem sobreposição | capturas |
| A20-08 | Todas as reduções funcionam | teste |
| A20-09 | Jogo divertido com tudo reduzido | playtest |
| A20-10 | Nenhuma informação só na cor, só no som ou só no háptico | auditoria |
| A20-11 | Checklist de acessibilidade 100 % | documento |
| A20-12 | Decisão sobre a engine documentada | ADR ou backlog |

## Gate da Beta

```text
[ ] tudo da Alpha continua verdadeiro
[ ] backend no ar (auth, perfil, leaderboard, cloud save, config, desafios)
[ ] analytics e crash reporting validados em produção
[ ] acessibilidade completa
[ ] matriz de dispositivos validada
[ ] performance dentro do orçamento nos 3 tiers
[ ] economia validada por simulação e por dados reais
[ ] onboarding final validado em playtest
[ ] segurança revisada (checklist de security.md)
[ ] crash-free sessions >= 99 % em teste fechado com >= 30 aparelhos
[ ] nenhum bug blocker ou crítico aberto
```
