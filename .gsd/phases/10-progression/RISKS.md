# GSD 10 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F10-01 | Progressão vazar para o gameplay e ferir o Pilar 5 | 2 | 5 | revisão específica no gate; nenhuma classe de progressão pode ser importada por `gameplay/`, `runner/` ou `territory/` (checagem de camadas) |
| F10-02 | Curva de XP frustrante (rápida demais ou lenta demais) | 3 | 3 | curva em `.tres`; simulação de 30 dias; ajuste por dado |
| F10-03 | Desafio antidivertido escapar para o pool | 3 | 3 | revisão do pool inteiro no gate; regra explícita em `progression.md` |
| F10-04 | Save inchar e ficar lento | 2 | 3 | orçamento de 100 KB; conquistas guardam progresso, não histórico |
| F10-05 | Virada de dia/fuso quebrar desafios | 3 | 3 | testes com fuso e relógio alterado; expiração calculada por data local, não por timer |
| F10-06 | Economia inflacionada antes de existir loja | 2 | 3 | `economy_sim` roda **antes** da GSD 11 |

## Riscos globais tocados
- **RISK-009** (perda de progresso): a primeira vez que existe progresso valioso para perder.
