# GSD 18 — Testes

## Unit
`test_analytics_service.gd` (contexto comum, nomes estáveis) · `test_batching.gd` (lote,
deduplicação, fila offline) · `test_optout.gd`

## API (Pest)
`TelemetryIngestTest` (lote válido/inválido, rate limit, agregação)

## Auditoria de privacidade
```text
[ ] payload inspecionado campo a campo
[ ] nenhum identificador de dispositivo, e-mail, contato ou localização
[ ] logs do servidor sem PII
[ ] retenção documentada
```

## Ponta a ponta
Build de produção, 10 partidas reais, todos os eventos conferidos + crash + perf + bateria e banda.
