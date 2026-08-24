# GSD 18 — Requisitos

| # | Requisito | Verificação |
|---|---|---|
| R18-01 | Nenhum sistema de gameplay chama analytics diretamente | inspeção |
| R18-02 | Todos os eventos de `analytics-plan.md` emitidos | teste |
| R18-03 | Contexto comum injetado pelo serviço | teste |
| R18-04 | Nenhum evento por frame; performance amostrada e agregada | inspeção |
| R18-05 | Envio em lote, com fila offline e sem duplicação | teste |
| R18-06 | **Zero PII** | auditoria de payload |
| R18-07 | Opt-out desliga o envio de verdade | teste de rede |
| R18-08 | Id de analytics rotacionável pelo jogador | manual |
| R18-09 | Crash reporting captura e envia com contexto útil | teste com crash forçado |
| R18-10 | `perf_sample` alimenta o orçamento de performance | consulta |
| R18-11 | Documentação de privacidade coerente com a coleta real | revisão |
| R18-12 | MOCK-002 fechado | `BACKLOG.md` |
