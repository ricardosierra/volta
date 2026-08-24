# GSD 19 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A19-01 | Todos os orçamentos de `performance-budget.md` respeitados | medição nos 3 tiers |
| A19-02 | 60 FPS no Mid sem hitch > 50 ms em 3 min | dispositivo |
| A19-03 | 120 FPS no High | dispositivo |
| A19-04 | 60 FPS no Low com preset Low | dispositivo |
| A19-05 | Memória plana em 10 partidas seguidas | medição |
| A19-06 | Cold start < 3 s; transições dentro do alvo | medição |
| A19-07 | Bateria < 8 %/hora; sem throttling em 20 min | medição |
| A19-08 | Tamanho dentro do orçamento | build |
| A19-09 | Benchmarks B01–B15 dentro do orçamento | relatório |
| A19-10 | Comportamento de IA inalterado após otimização | 500 partidas comparadas |
| A19-11 | Nenhuma perda visual perceptível | comparação lado a lado |
| A19-12 | Toda otimização com antes/depois documentado | PRs |
| A19-13 | Baselines atualizados e gate de regressão ativo | CI |
