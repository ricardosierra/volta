# Offline-First Validation Report

> **Status: NÃO EXECUTADO.** Revisado em 2026-08-31 durante a auditoria das fases 10–25.
> A versão anterior registrava três cenários com resultado PASS. Nenhum deles podia ter sido
> executado: os componentes que eles testariam não estão ligados ao jogo, e um deles não
> implementa o comportamento afirmado.

## Por que este relatório foi reescrito

A versão anterior afirmava:

- *Cenário 1 (modo avião)* — progressão salva localmente e **enfileirada para upload**: PASS
- *Cenário 2 (servidor lento, 5 s)* — boot não bloqueia em Config nem Leaderboard: PASS
- *Cenário 3 (servidor fora, erro 500)* — submissão de partida **repetida com backoff
  exponencial via OfflineQueue**: PASS

A verificação no código contradiz os três:

- `apps/mobile/src/platform/api/offline_queue.gd` implementa **apenas** `enqueue()`,
  `_load_queue()` e `_save_queue()`. **Não existe drenagem, não existe retry, não existe
  backoff exponencial e não existe nenhuma chamada de rede.** O Cenário 3 descreve um
  comportamento que não está escrito.
- `OfflineQueue` só é citado por `apps/mobile/src/progression/remote_profile_repository.gd`,
  que por sua vez não é referenciado por nada — nem em `bootstrap.gd` (que registra apenas
  `quality`, `haptics`, `vfx`, `wallet`, `catalog`, `profile_repo`), nem em `[autoload]`.
  A fila nunca é instanciada em tempo de execução.
- `RemoteProfileRepository.load_profile()` (linha 16) chama `local_cache.load_profile()`, mas
  `LocalProfileRepository` define `get_profile()` (linha 6). A chamada quebraria em execução —
  outro indício de que este caminho nunca rodou.
- Não há backend para ficar "lento" ou "fora": `services/api/` não tem `composer.json` nem
  `artisan`, e `AuthController.php:20` registra que o token é simulado.

## O que está de fato verificado

| Item | Estado | Evidência |
|---|---|---|
| `OfflineQueue` persiste em disco | Sim, isoladamente | `offline_queue.gd` grava `user://offline_queue.json` |
| Fila é drenada / reenviada | **Não implementado** | sem método de drenagem no arquivo |
| Retry com backoff exponencial | **Não implementado** | nenhuma referência a retry/backoff |
| Repositórios remotos ativos | **Não** | nunca instanciados |
| Save local resiliente | Sim | `SaveService`/`FileSaveService` estão ligados e cobertos por teste |

O comportamento offline que **de fato** existe hoje é o save local atômico da Fase 1 — esse é
real e testado. O que não existe é a camada de sincronização por cima dele.

## O que falta para validar de verdade

1. Implementar drenagem e política de retry em `OfflineQueue`, com idempotência de verdade.
2. Registrar `ApiClient`, `OfflineQueue` e os repositórios remotos em `bootstrap.gd`.
3. Corrigir `RemoteProfileRepository.load_profile()` → `get_profile()`.
4. Tornar `services/api/` executável para haver um servidor a derrubar nos cenários.
5. Só então rodar os três cenários com evidência (log, captura ou teste automatizado).

Isto é pré-requisito direto da Fase 27, que planeja reusar este padrão para a fila
`pending_game_events` da integração com o Google Play Games.
