# GSD 15 — Testes (Pest)

## Feature
`AuthDeviceTest` · `ProfileTest` (incl. sanitização) · `MatchSubmissionTest` (válida, duplicada,
implausível ×8, assinatura inválida) · `LeaderboardTest` (ordenação, empate, paginação, `me`,
virada de período) · `CloudSaveTest` (conflito, blob inválido, versão futura, restauração) ·
`ChallengeTest` (rotação, resgate único, fuso) · `RemoteConfigTest` (ETag, chave nova, faixa) ·
`RateLimitTest` · `IdempotencyTest`

## Unit
Serviço de score (mesma fórmula do cliente) · validador de plausibilidade · reconciliação
monotônica · sanitizador de apelido

## Integração
Job de processamento de partida → leaderboard atualizado · reconstrução de ZSET a partir do
Postgres · rotação diária de desafios

## Operação
```text
[ ] migrate e rollback limpos
[ ] backup diário gerado
[ ] restauração testada em ambiente limpo
[ ] health check responde
[ ] composer audit sem vulnerabilidade conhecida
```

## Performance
p95 < 200 ms nas rotas principais · leaderboard < 50 ms · 100 submissões concorrentes sem
duplicação
