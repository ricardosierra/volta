# GSD 00 — Riscos da fase

| # | Risco | Estado | Mitigação aplicada |
|---|---|---|---|
| F00-01 | Planejar demais e nunca implementar | ✅ contido | O plano termina aqui; a GSD 01 já é código. Fases futuras têm plano detalhado mas revisável (`Plan GSD XX`) |
| F00-02 | Plano detalhado demais que envelhece mal | ⚠️ monitorar | Fases distantes (15–25) são detalhadas em objetivo e aceite, com tarefas que podem ser refinadas antes da execução |
| F00-03 | Decisão fundamental esquecida, descoberta na GSD 03 | ✅ contido | Varredura explícita (A00-14): cada fase foi lida procurando dependência de decisão não tomada |
| F00-04 | Números de balanceamento inventados sem base | ⚠️ aceito | Todos marcados 🎯 como alvo inicial; o stress test da GSD 05 é o primeiro ajuste por dado |
| F00-05 | Semelhança acidental com produto existente | ⚠️ monitorar | Glossário, regras, economia e arte próprios; RISK-012 cobre a marca; revisão antes da GSD 21 |
| F00-06 | Escopo do v0.1.0 grande demais | ⚠️ monitorar | Marcos com critério objetivo; `BACKLOG.md` já contém 18 itens deliberadamente adiados |

## Riscos herdados para as próximas fases

Registrados em [`../../RISKS.md`](../../RISKS.md): RISK-001 a RISK-020.
Os de score ≥ 12 (001, 002, 003, 004, 006, 012) já têm ação embutida no plano.
