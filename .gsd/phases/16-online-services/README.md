# GSD 16 — Online Services

**Status:** ⬜ pendente · **Depende de:** GSD 15 · **Tarefas:** 9 · **Prefixo:** `ONLN`
**Branch:** `feature/gsd-16-online-services`

## Objetivo

> Trocar `Local*` por `Remote*` no bootstrap — e provar que, sem rede, **nada** muda para quem
> está jogando.

## Escopo

**Entra:** `ApiClient` com timeout, retry e idempotência · fila offline persistente ·
`RemoteLeaderboardRepository` (fecha MOCK-001) · `RemoteProfileRepository` · cloud save ·
`RemoteChallengeRepository` (fecha MOCK-004) · `HttpRemoteConfig` (fecha MOCK-003) ·
tela de Leaderboard · vinculação opcional de conta · indicador discreto de sincronização.

**NÃO entra:** multiplayer (é 17) · telemetria (é 18) · compras (é 25).
