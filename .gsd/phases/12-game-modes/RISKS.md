# GSD 12 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F12-01 | Modos viram ramos espalhados no código | 3 | 4 | tudo em `MatchRulesResource`; `grep "if mode =="` é critério de aceite |
| F12-02 | Endless vazar memória em partidas longas | 3 | 4 | teste de 30 min; invariante de memória; pooling já obrigatório |
| F12-03 | Reset Pulse causar Squeeze acidental e eliminação injusta | 3 | 3 | regra explícita: nunca zera Claim; teste dedicado |
| F12-04 | Survival escalar por velocidade "porque é mais fácil" | 2 | 5 | proibido por R8.1; teste de inspeção + verificação no stress |
| F12-05 | 5 modos multiplicarem o custo de QA | 3 | 3 | stress test automatizado por modo; a matriz de testes cresce, o esforço manual não |
| F12-06 | Um modo ficar claramente pior e diluir o produto | 2 | 3 | critério "o que ele faz de diferente?" no gate; modo fraco vira preset, não modo |

## Riscos globais tocados
- **RISK-006** (escopo): 4 modos é o limite planejado; qualquer modo novo vai para o backlog.
