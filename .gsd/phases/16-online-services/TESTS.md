# GSD 16 — Testes

## Unit
`test_api_client.gd` (timeout, retry, backoff, idempotência) · `test_offline_queue.gd`
(persistência, deduplicação, ordem, limite) · `test_remote_config_validation.gd`

## Integration
`test_offline_play.gd` (partida completa sem rede) · `test_sync_after_reconnect.gd` ·
`test_cloud_save_conflict.gd` (nos dois sentidos) · `test_challenge_fallback.gd`

## Cenários de rede (obrigatórios, em dispositivo)
```text
[ ] modo avião do começo ao fim
[ ] rede caindo no meio de uma partida
[ ] servidor retornando 500
[ ] servidor lento (5 s de latência)
[ ] app morto com fila pendente
[ ] troca de aparelho com cloud save
```

## Performance
Boot não aumenta com rede lenta · leaderboard com cache < 500 ms · fila drena sem hitch
