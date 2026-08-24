# GSD 25 — Critérios de aceite (por ciclo)

| # | Critério | Como verificar |
|---|---|---|
| A25-01 | Crash-free ≥ 99,5 % mantido | analytics |
| A25-02 | Todo ajuste de balanceamento com antes/depois medido | `balance.md` |
| A25-03 | Nenhum item novo altera a simulação | revisão |
| A25-04 | Nenhum dark pattern | revisão contra `monetization.md` |
| A25-05 | Anúncios dentro dos limites definidos | inspeção |
| A25-06 | Compras validadas no servidor | teste |
| A25-07 | Conteúdo novo passa pelos gates de qualidade | quality gates |
| A25-08 | Métricas de saúde econômica dentro das faixas | painel |
| A25-09 | Cada release segue o processo e o formato de CHANGELOG | inspeção |
| A25-10 | Retenção D1/D7 estável ou melhorando | analytics |

## North Star (vale para toda decisão pós-launch)

```text
Fun > Responsiveness > Clarity > Game Feel > Performance > Visual Quality > Retention > Monetization
```

Se uma mudança melhora receita e piora qualquer item acima de "Monetization", ela não entra.
