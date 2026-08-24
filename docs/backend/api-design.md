# API — design

> Só existe a partir de **GSD 15**. Até lá, o cliente usa repositórios locais com a mesma
> forma de interface. Stack decidida em [`ADR-0004`](../decisions/ADR-0004-backend.md).

## Stack

PHP 8.3 · Laravel 11 · PostgreSQL 16 · Redis 7 (cache, filas, leaderboard) · Sanctum ·
Horizon (filas) · Pest/PHPUnit · Pint · PHPStan nível 6+.

## Princípios

1. **O cliente nunca é fonte de verdade** para score, moeda, inventário ou progresso.
2. Toda rota autenticada tem rate limit e validação de plausibilidade.
3. Escritas são **idempotentes** (`Idempotency-Key`).
4. Versionamento no caminho: `/api/v1/...`. Quebra de contrato exige `v2`.
5. Respostas são envelopes previsíveis; erros seguem um formato único.
6. Nada de lógica em controller: `Controller → FormRequest → Action/Service → Repository`.

## Autenticação

Conta anônima por dispositivo no primeiro contato (sem cadastro, sem e-mail):

```http
POST /api/v1/auth/device
{ "device_id": "<uuid>", "platform": "android", "app_version": "0.1.0" }
→ 201 { "player_id": "...", "token": "...", "created": true }
```

Vinculação opcional a provedor (Google Play Games / Game Center) vem depois, para recuperar
conta em troca de aparelho. Nunca pedimos e-mail para jogar.

## Rotas (v1)

| Método | Rota | Descrição | Auth |
|---|---|---|---|
| `POST` | `/auth/device` | criar/obter conta de dispositivo | — |
| `POST` | `/auth/refresh` | renovar token | ✅ |
| `GET` | `/profile` | perfil, rank, estatísticas | ✅ |
| `PATCH` | `/profile` | apelido, título, avatar equipado | ✅ |
| `GET` | `/save` | baixar blob de cloud save | ✅ |
| `PUT` | `/save` | enviar blob (com `updated_at` e resolução de conflito) | ✅ |
| `POST` | `/matches` | submeter resultado de partida (assinado) | ✅ |
| `GET` | `/leaderboards/{board}` | `daily`\|`weekly`\|`monthly`\|`all_time`\|`friends`\|`country` | ✅ |
| `GET` | `/leaderboards/{board}/me` | posição e vizinhança do jogador | ✅ |
| `GET` | `/challenges/daily` | desafios do dia (mesmos para todos) | ✅ |
| `POST` | `/challenges/{id}/claim` | resgatar recompensa | ✅ |
| `GET` | `/config` | remote config (com `ETag`) | ✅ |
| `GET` | `/inventory` | cosméticos possuídos | ✅ |
| `POST` | `/purchases/verify` | validar recibo de loja | ✅ |
| `POST` | `/telemetry` | lote de eventos | ✅ |
| `GET` | `/health` | health check | — |

## Envelope

```json
{ "data": { }, "meta": { "server_time": "2026-09-01T12:00:00Z", "version": "v1" } }
```

```json
{ "error": { "code": "score_implausible", "message": "…", "details": { } } }
```

Códigos de erro são `snake_case` estáveis — o cliente **nunca** faz parse de mensagem.

## Submissão de partida

```http
POST /api/v1/matches
{
  "match_id": "<uuid>", "mode": "classic", "arena": "open_field",
  "duration_ms": 180000, "claim_pct": 0.34, "score": 18240,
  "breaks": 3, "deaths": 1, "largest_seal_pct": 0.11, "max_surge": 4,
  "seals": 12, "events_digest": "<hash>", "client_version": "0.1.0",
  "signature": "<hmac>"
}
```

O servidor **recalcula** o score a partir dos agregados declarados, valida contra os limites
físicos do modo (ver `anti-cheat.md`) e só então grava e atualiza o leaderboard.
Divergência acima da tolerância → `422 score_mismatch`, registro para análise, **sem** banir
automaticamente.

## Modelo de dados (resumo)

```text
players(id, device_id_hash, nickname, rank, xp, created_at, banned_at, ...)
player_stats(player_id, matches, wins, breaks, deaths, cells_captured, ...)
matches(id, player_id, mode, arena, score, claim_pct, duration_ms, created_at, flags)
leaderboard_entries(board, period_key, player_id, score, updated_at)   # + ZSET no Redis
inventory(player_id, item_id, acquired_at, source)
challenges(id, period_key, definition, reward)
challenge_progress(player_id, challenge_id, progress, claimed_at)
saves(player_id, blob, schema_version, updated_at)
purchases(id, player_id, sku, platform, receipt_hash, status, verified_at)
```

Leaderboard usa **Redis ZSET** como camada quente e PostgreSQL como verdade durável;
reconciliação por job periódico.

## Filas

`match.process` (validar, pontuar, atualizar leaderboard) · `telemetry.ingest` ·
`leaderboard.rebuild` · `challenge.rotate` (diário) · `purchase.verify`.

## Rate limits 🎯

| Rota | Limite |
|---|---|
| `POST /auth/device` | 5/min por IP |
| `POST /matches` | 30/h por jogador (uma partida dura ≥ 60 s) |
| `GET /leaderboards/*` | 60/min |
| `PUT /save` | 20/h |
| `POST /telemetry` | 12/min (lotes) |

## Testes

Pest com cobertura de: auth, idempotência, validação de score, conflito de cloud save,
rate limit, permissões, rotação de desafio, verificação de compra. Sem esses, a fase 15 não fecha.
