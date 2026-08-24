# GSD 18 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A18-01 | Nenhum sistema de gameplay chama analytics diretamente | inspeção |
| A18-02 | Todos os eventos do plano chegam com as propriedades certas | validação ponta a ponta |
| A18-03 | Zero PII no payload | auditoria campo a campo |
| A18-04 | Opt-out impede qualquer envio | teste com proxy |
| A18-05 | Id rotacionável pelo jogador | manual |
| A18-06 | Crash capturado com contexto útil | crash forçado |
| A18-07 | `perf_sample` responde "roda bem no aparelho X?" | consulta |
| A18-08 | Nenhum evento por frame; banda desprezível | medição |
| A18-09 | Documentação de privacidade coerente com a coleta | revisão |
| A18-10 | MOCK-002 fechado | `BACKLOG.md` |
