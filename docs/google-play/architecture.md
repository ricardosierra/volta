# Arquitetura de Integração — Google Play Games (VOLTA)

> Este documento é o Plano 03 da Fase 26. Ele desenha e VALIDA a arquitetura de integração
> Gameplay → Domain Events → Gamification Engine → Integração Google contra o código real do
> projeto (não contra uma arquitetura ideal ou lembrada de memória). Toda afirmação sobre
> "estado atual" cita um arquivo real, lido nesta mesma tarefa ou herdado de
> [`docs/google-play/compatibility-audit.md`](./compatibility-audit.md) (Plano 01) e
> [`docs/google-play/current-requirements.md`](./current-requirements.md) (Plano 02).
>
> Convenção de citação: `arquivo.gd` sempre se refere a `apps/mobile/src/.../arquivo.gd`, com o
> caminho completo dado na primeira menção de cada arquivo.

---

## 1. Visão Geral do Pipeline

A integração com o ecossistema Google Play Games segue uma cadeia de 4 camadas, cada uma
mapeada para um lugar concreto (existente ou a criar) na árvore real de
`apps/mobile/src/`:

```text
┌─────────────┐     ┌────────────────┐     ┌──────────────────────┐     ┌────────────────────┐
│  Gameplay   │ ──▶ │  Domain Events │ ──▶ │  Gamification Engine │ ──▶ │  Integração Google  │
│  (emite)    │     │  (transporte)  │     │  (regra de negócio)  │     │  (fala com o SDK)   │
└─────────────┘     └────────────────┘     └──────────────────────┘     └────────────────────┘
 gameplay/            core/event_bus.gd       progression/gamification/    platform/google_play/
 progression/*        core/events/*.gd        (novo módulo)                (novo módulo)
 (emissores hoje)     (EventBus real +
                       payloads tipados
                       novos)
```

1. **Gameplay** — `apps/mobile/src/gameplay/` e `apps/mobile/src/progression/` são os
   ÚNICOS pontos que sabem que algo aconteceu na partida ou na progressão (uma partida
   terminou, um Seal fechou, um Runner morreu, um nível subiu). Hoje esses fatos já existem
   como **signals locais**, não como eventos de domínio: `MatchDirector.match_ended(result)` e
   `MatchDirector.final_push_started` em `apps/mobile/src/gameplay/match_director.gd`,
   `EliminationService.runner_eliminated(victim, killer, cause)` em
   `apps/mobile/src/gameplay/elimination_service.gd`, `SurgeService.surge_level_changed(...)`
   em `apps/mobile/src/gameplay/score/surge_service.gd`,
   `AchievementService.achievement_unlocked(ach)` em
   `apps/mobile/src/progression/achievements/achievement_service.gd`. **`gameplay/` (e
   `territory/`, `runner/`, `ai/`) NUNCA importam um SDK do Google, nem direta nem
   indiretamente** — a única saída permitida para essas camadas é emitir um evento de domínio
   via EventBus. Esta é a extensão direta da regra 5 de `CLAUDE.md` (`territory/`, `runner/`,
   `ai/`, `gameplay/` não importam `presentation/`/`ui/`): se essas camadas não podem depender
   de uma camada acima para desenhar, também não podem depender de um SDK de terceiros para
   falar com um servidor do Google — o motivo é o mesmo (a simulação tem que rodar headless,
   determinística e sem I/O, ver `docs/architecture/overview.md` §7 e §9 "❌ `await` em caminho
   de simulação").
2. **Domain Events (transporte)** — vive em `apps/mobile/src/core/event_bus.gd` (a classe
   `EventBus` real, hoje com 4 sinais primitivos de infraestrutura) e nos payloads tipados de
   `apps/mobile/src/core/events/`, cujo `README.md` já reserva esse diretório para exatamente
   este propósito ("Payloads tipados para eventos complexos entram aqui conforme necessário").
   Esta fase de arquitetura formaliza que a Fase 27 deve criar ali um payload por evento novo
   (`MatchStartedEvent`, `MatchEndedEvent`, `SealCompletedEvent`, `RunnerEliminatedEvent`,
   `LevelUpEvent`, etc.), e estender `EventBus` com um método `emit_<evento>()` para cada um,
   seguindo exatamente o padrão de `emit_config_loaded()` / `emit_save_loaded(result)` já
   existente no arquivo. **Não se cria um segundo barramento** — o `EventBus` existente é o
   único ponto de emissão desacoplada do projeto (confirmado como o mecanismo correto por
   `docs/architecture/overview.md` §3, tabela "Três mecanismos de comunicação": "EventBus →
   evento global, muitos ouvintes desacoplados, baixa frequência").
3. **Gamification Engine (regra de negócio)** — módulo NOVO, que não existe hoje no
   repositório. Vive como extensão de `apps/mobile/src/progression/` — concretamente um novo
   subdiretório `apps/mobile/src/progression/gamification/` — porque a linha de camadas de
   `docs/architecture/overview.md` §1 já coloca `progression/` no mesmo nível de `platform/` e
   `core/` (o nível que pode ser consumido por `gameplay/` mas nunca o contrário), e é
   exatamente aí que uma regra "quando X eventos de Seal acontecem, subir a stat de progresso"
   ou "quando `RunnerEliminated` bate no critério do achievement `first_blood`, marcar
   progresso" deve morar — reaproveitando (não substituindo) o que já existe:
   `AchievementService` (`apps/mobile/src/progression/achievements/achievement_service.gd`),
   `XpService` (`apps/mobile/src/progression/xp_service.gd`), `ChallengeService`
   (`apps/mobile/src/progression/challenges/challenge_service.gd`) e `StatsService`
   (`apps/mobile/src/progression/stats_service.gd`). O Gamification Engine **escuta** o
   `EventBus` (nunca o inverso) e, ao aplicar suas regras, **também emite** eventos de domínio
   derivados de volta no mesmo `EventBus` (`AchievementProgressed`, `LevelUp`,
   `DailyChallengeCompleted`) — ele é ao mesmo tempo consumidor de eventos brutos de gameplay e
   produtor de eventos de progresso, o que faz da Seção 3 abaixo uma tabela com dois "tipos" de
   evento (brutos e derivados), tratados de forma idêntica pelo transporte.
4. **Integração Google** — vive em `apps/mobile/src/platform/`, ao lado de
   `apps/mobile/src/platform/analytics/` e `apps/mobile/src/platform/api/` que já existem hoje.
   Um novo subdiretório `apps/mobile/src/platform/google_play/` hospeda um adaptador por
   superfície (`PlayGamesAuthAdapter`, `PlayGamesAchievementsAdapter`, `GameStatsAdapter`,
   `PlayGamesLeaderboardRepository`, `PlayGamesRewardsAdapter`), cada um **escutando** o
   `EventBus` (nunca sendo chamado diretamente por `gameplay/` ou pelo Gamification Engine) e
   traduzindo o evento de domínio numa chamada real ao SDK Java/Kotlin do Play Games Services.
   Isso é o mesmo padrão já usado por `AnalyticsService`/`RemoteAnalytics`
   (`apps/mobile/src/platform/analytics/`) e por `LeaderboardRepository`/
   `RemoteLeaderboardRepository` (`apps/mobile/src/progression/leaderboard/`): uma interface
   fina, uma implementação real que fala com um serviço externo, e o resto do jogo nunca sabe
   qual implementação está ativa.

**Por que a cadeia inteira existe, e não uma chamada direta gameplay → SDK:** todo I/O de SDK
do Play Games (autenticação, submissão de Achievement/Score, Recall, Saved Games, Rewards) é
assíncrono por natureza (confirmado em `docs/google-play/current-requirements.md` seções 1–13).
`docs/google-play/compatibility-audit.md` §1.1 já registrou que **não existe hoje nenhuma
checagem de CI contra `await` no caminho de simulação** — a cadeia de 4 camadas com EventBus no
meio é precisamente o que torna essa checagem desnecessária de reforçar por disciplina manual:
fisicamente não há como um SDK assíncrono do Google chegar a `territory/`, `runner/`, `ai/` ou
`gameplay/`, porque essas camadas apenas emitem `Signal.emit()` sem retorno e sem `await`.

---

## 2. Compatibilidade com a Arquitetura Existente

**Validação explícita contra `docs/architecture/overview.md` §1 (regra de dependência):** o
desenho da Seção 1 **não** viola a regra "uma camada só pode depender de camadas abaixo dela".
`gameplay/` (camada intermediária, junto de `territory/`, `runner/`, `ai/`, `arena/`) já tem
permissão de depender da camada de baixo (`input/`, `progression/`, `platform/`, `core/`) —
mas esta arquitetura escolhe **não exercer** essa permissão para o caso específico do SDK
Google: em vez de `gameplay/` chamar `platform/google_play/` diretamente (o que seria
permitido pela regra de camadas, mas criaria acoplamento direto a um SDK assíncrono de
terceiros dentro do caminho de simulação), `gameplay/` só fala com `core/event_bus.gd`, que é a
camada mais baixa de todas ("`core/` não importa ninguém", `docs/architecture/overview.md`
§1). O Gamification Engine (`progression/gamification/`, nova) e os adaptadores Google
(`platform/google_play/`, novo) ficam ambos no mesmo nível de camada de `progression/` e
`platform/` hoje — nenhum dos dois fica "abaixo" de `core/`, respeitando literalmente a
restrição da tarefa ("nunca abaixo de `core/`"). Nenhuma dependência nova é criada de uma
camada de cima para uma de baixo em sentido proibido; a única dependência nova de fato é
`platform/google_play/*` → `core/event_bus.gd` (escuta), que é exatamente o sentido permitido.

**O `EventBus` atual é o padrão a ESTENDER, não substituir.** `apps/mobile/src/core/event_bus.gd`
hoje define exatamente 4 sinais, todos primitivos e de baixa frequência: `config_loaded()`,
`config_load_failed(reason: String)`, `save_loaded(result: int)`, `save_written()`. Cada
`emit_*()` desses passa por `_track_emission()`, que em build de debug
(`Build.is_debug()`) cronometra emissões numa janela de 1 segundo e aciona `push_warning` acima
de `MAX_EMISSIONS_PER_SECOND = 5` **por sinal**. Os 8 eventos novos da Seção 3 seguem
literalmente o mesmo padrão de método (`emit_match_started()`, `emit_seal_completed()`, etc.),
cada um com seu próprio contador de limite — o limite é por `signal_name`, não global, então
adicionar sinais novos não consome o orçamento de emissão dos sinais existentes
(`config_loaded` continua com seu próprio teto de 5/seg, `MatchStarted` tem o dele).

**O limite de 5 emissões/seg não é um risco real para os eventos de fim de partida ou de
progresso.** `MatchStarted` e `MatchEnded` ocorrem no máximo 1 vez por partida (partidas duram
90–180 s per `docs/product/vision.md`) — muito abaixo do teto. `LevelUp` e
`AchievementProgressed` ocorrem no máximo algumas vezes por partida. O único evento desta lista
com frequência potencialmente alta é `SealCompleted` (um jogador hábil pode fechar vários Seals
pequenos em sequência): mesmo assim, um Seal físico tem custo de resolução medido em
`docs/performance/territory-benchmarks.md` (a Fase 3 já provou p95 < 0,8 ms por Seal típico, o
que limita fisicamente quantos Seals cabem por segundo de gameplay real) — na prática, estourar
5 `SealCompleted`/segundo exigiria um jogador fechando um território a cada 200 ms, fora da
janela de jogabilidade observada em qualquer playtest registrado nas fases anteriores. Ainda
assim, esta arquitetura recomenda que a Fase 27, ao implementar `emit_seal_completed()`, trate
o `push_warning` de limite excedido como sinal de telemetria a observar (não como bug a
silenciar) em vez de simplesmente subir o teto sem medir — mesma disciplina de "medir antes de
mudar" já em vigor no projeto (`docs/performance/performance-budget.md`).

**Nenhum SDK de integração Google é importado por `territory/`, `runner/`, `ai/` ou
`gameplay/`.** A única forma de esses diretórios influenciarem algo relacionado ao Google é por
meio dos métodos `emit_*()` do `EventBus`, que não retornam nada e não fazem I/O. Os
adaptadores em `platform/google_play/` são os únicos arquivos do projeto autorizados a conter
`import`/referência ao plugin ou SDK Java/Kotlin do Play Games Services.

---

## 3. Eventos de Domínio Necessários

A tabela cobre os 8 eventos mínimos exigidos por este plano. "Emissor" cita o arquivo real que
hoje já produz o fato equivalente como signal local (quando existe) ou o ponto de extensão
onde o evento deve nascer (quando o fato ainda não é observável no código, registrado
explicitamente como tal). "Fase que implementa" é a fase do ROADMAP dona da entrega funcional
que consome esse evento pela primeira vez — a infraestrutura de emissão em si (o método
`emit_*()` no `EventBus` e o payload em `core/events/`) é sempre criada pela Fase 27, mesmo
quando a coluna aponta para uma fase posterior como consumidora principal.

| Evento | Payload | Emissor | Consumidores | Fase que implementa |
|---|---|---|---|---|
| `MatchStarted` | `match_id: String`, `mode: String`, `timestamp: float` | `apps/mobile/src/gameplay/match_director.gd` (`setup_match`), hoje já observável indiretamente via `AnalyticsBridge.on_match_started` em `apps/mobile/src/gameplay/analytics_bridge.gd` | Gamification Engine (contagem de sessões para quests diárias), `platform/analytics` | Fase 27 |
| `MatchEnded` | `match_id: String`, `winner_id: int`, `cause: String`, `duration_sec: float`, `placements: Array[Dictionary]` | `apps/mobile/src/gameplay/match_director.gd` (signal local `match_ended(result: MatchResult)`, hoje sem EventBus) | `XpService` (add_xp por partida), `StatsService`, Gamification Engine (streaks/quests), `PlayGamesLeaderboardRepository` (Fase 32) | Fase 27 |
| `SealCompleted` | `runner_id: int`, `cells_captured: int`, `stolen_cells: int`, `is_largest_seal: bool` | `apps/mobile/src/gameplay/score/score_service.gd` (`handle_seal`), hoje só atualiza `ScoreState` sem emitir sinal — ponto de extensão a criar na Fase 27 | `AchievementService` (novo critério de território), Game Stats (repetitive stat "maior Seal"), Rewards de quest | Fase 29 |
| `RunnerEliminated` | `victim: int`, `killer: int`, `cause: String` | `apps/mobile/src/gameplay/elimination_service.gd` (signal local `runner_eliminated(victim, killer, cause)`, hoje sem EventBus) | `AchievementService` (`first_blood`), `StatsService` (`total_kills`/`total_deaths`), anti-cheat (Fase 35) | Fase 29 |
| `AchievementProgressed` | `achievement_id: String`, `current: int`, `target: int`, `unlocked: bool` | Gamification Engine — extensão de `apps/mobile/src/progression/achievements/achievement_service.gd` (hoje só emite `achievement_unlocked(ach)` no desbloqueio final, sem progresso incremental) | `PlayGamesAchievementsAdapter` (`platform/google_play/`, novo), UI de progresso, contagem para o "achievements badge" do Sidekick (100 jogadores/30 dias, `current-requirements.md` §10) | Fase 29 |
| `LevelUp` | `player_id: String`, `old_level: int`, `new_level: int`, `total_xp: int` | `apps/mobile/src/progression/xp_service.gd` (`_on_level_up`, hoje um método vazio com o comentário `# Emit particles, unlock frames`) | `UnlockService` (`apps/mobile/src/progression/cosmetics/unlock_service.gd`, desbloqueio por nível), Game Stats (`progressUpdate`, `current-requirements.md` §7), Rewards | Fase 30 |
| `DailyChallengeCompleted` | `challenge_id: String`, `player_id: String`, `reward_type: String`, `reward_amount: int` | `apps/mobile/src/progression/challenges/challenge_service.gd` (hoje `# MOCK-004`, sem emissão de evento — geração mockada, ver `compatibility-audit.md` §2.2) | `Wallet` (`apps/mobile/src/progression/wallet.gd`, concessão de Sparks), `PlayGamesRewardsAdapter` (Fase 31), `SeasonService` (LiveOps, Fase 33) | Fase 31 |
| `PowerUpCollected` | `runner_id: int`, `power_up_type: String`, `match_id: String` | `apps/mobile/src/gameplay/powerups/power_up_service.gd` (`apply_effect`, hoje não emite nenhum sinal no momento da coleta — ponto de extensão a criar) | Game Stats (repetitive stat "power-ups usados"), `AchievementService` (conquistas de exploração) | Fase 30 |

Todos os 8 eventos acima nascem como método novo em `apps/mobile/src/core/event_bus.gd`
(`emit_match_started()`, `emit_match_ended()`, `emit_seal_completed()`,
`emit_runner_eliminated()`, `emit_achievement_progressed()`, `emit_level_up()`,
`emit_daily_challenge_completed()`, `emit_power_up_collected()`) e um payload correspondente em
`apps/mobile/src/core/events/`, seguindo a convenção já declarada pelo `README.md` daquele
diretório.

---

## 4. Feature Flags e Fila Offline

**Convenção de nome de feature flag:** `google_play_<superficie>`, em snake_case, uma flag por
superfície Google (nunca uma flag genérica "google_play_enabled" cobrindo tudo, porque cada
superfície tem seu próprio gate de disponibilidade documentado em
`docs/google-play/current-requirements.md` §14). Nomenclatura concreta, alinhada ao texto do
Success Criterion 3 da Fase 27 no ROADMAP ("Feature flags para todos os novos sistemas (ex:
`google_play_sidekick`, `game_stats`)"):

| Flag | Superfície | Default recomendado | Motivo |
|---|---|---|---|
| `google_play_pgs_v2` | Sign-In (Fase 28) | `false` até Gradle build customizado existir | Pré-requisito técnico bloqueante (ver Seção 5, Fase 28) |
| `google_play_achievements` | Achievements (Fase 29) | `false` até catálogo mapeado | GA, mas depende de conteúdo pronto |
| `google_play_game_stats` | Game Stats (Fase 30) | `false` até CSVs configurados no Play Console | API disponível, UI pública "You tab" só GA em set/2026 (`current-requirements.md` §7) |
| `google_play_rewards` | Play Games Rewards (Fase 31) | `false` até 01/09/2026 | Feature só entra em vigor nessa data (`current-requirements.md` §13) |
| `google_play_points` | Play Points (Fase 31) | `false` (hard gate) | Invite-only/allowlist — não ativar sem confirmação de aceite do Google (`current-requirements.md` §8) |
| `google_play_leaderboards` | Leaderboards (Fase 32) | `false` até `PlayGamesLeaderboardRepository` existir | Convive com o leaderboard próprio, não o substitui |
| `google_play_sidekick` | Sidekick (Fase 34) | `true` (ativação é toggle de Play Console, sem SDK) | VOLTA publica em AAB — Sidekick liga por padrão (`current-requirements.md` §10) |
| `google_play_integrity` | Play Integrity (Fase 35) | `false` até backend validar veredictos | Requer endpoint novo no backend próprio |

Cada flag é resolvida pelo mesmo mecanismo de Remote Config já esboçado em
`apps/mobile/src/core/config/http_remote_config.gd` (`HttpRemoteConfig`, hoje um cliente fino
contra `GET /config`) — a Fase 27 estende esse serviço (ou cria `BakedRemoteConfig` como
fallback embutido, citado como planejado em `docs/architecture/networking.md`) para expor
`get_value("google_play_achievements", false)` e falhar seguro (`false`) em qualquer erro de
rede, replicando a regra já documentada em `docs/architecture/networking.md` §"Remote config
nunca é aplicado durante `Playing`, cai no embutido em qualquer falha".

**Fila offline `pending_game_events`:** reaproveita explicitamente o padrão de persistência já
implementado em `apps/mobile/src/platform/api/offline_queue.gd` (`class_name OfflineQueue`) —
mesma primitiva de serialização (`JSON.stringify`/`JSON.parse` para `user://<nome>.json`, carga
em `_ready()`, gravação a cada `enqueue()`). A Fase 27 cria uma segunda fila,
`user://pending_game_events.json`, gerenciada por uma nova classe (`PendingGameEventsQueue` ou
extensão parametrizada de `OfflineQueue`) com o mesmo formato de item (`endpoint`/`method`
substituídos por `event_name`/`payload`/`idempotency_key`), para os eventos de domínio que
precisam alcançar um adaptador Google e a rede está indisponível no momento da emissão. Isso
fecha explicitamente a lacuna já registrada em `docs/google-play/compatibility-audit.md` §2.5:
**`OfflineQueue` hoje não tem nenhum mecanismo de drenagem/retry** ("os itens só entram, nunca
são explicitamente removidos ou reenviados por este arquivo") — a Fase 27 não pode apenas
copiar o arquivo, precisa adicionar o `flush()`/`drain()` que falta, com idempotência via
`idempotency_key` (mesmo campo que `ApiClient`, `apps/mobile/src/platform/api/api_client.gd`,
já usa no header `Idempotency-Key`) para garantir que um evento de progresso nunca seja
reportado duas vezes ao Google quando a fila é drenada após reconexão.

Fluxo completo: `EventBus.emit_seal_completed(...)` → Gamification Engine processa e decide que
`PlayGamesAchievementsAdapter` precisa ser notificado → o adaptador tenta a chamada ao SDK; se
falhar por rede, o item entra em `pending_game_events` com o mesmo `idempotency_key` do evento
de origem; um `drain()` (rodado no boot e em reconexão de rede, nunca dentro do tick de
simulação) tenta reenviar cada item pendente, removendo-o só após confirmação — mesmo modelo
"nunca bloqueia o gameplay" já em vigor para leaderboard remoto
(`docs/architecture/networking.md` §1).

---

## 5. Mapeamento de Fases (27-38)

Tabela derivada dos goals de cada fase em `.planning/ROADMAP.md` ("### Phase 27" até
"### Phase 38"), cruzada com os sistemas já auditados em `docs/google-play/compatibility-audit.md`
§3 e com os bloqueadores registrados em `docs/google-play/current-requirements.md` §14.

| Fase | Superfície Google | Sistema Existente Reaproveitado | Novo Componente Necessário |
|---|---|---|---|
| Fase 27 — Gamification Foundation | Nenhuma diretamente (fundação interna, pré-requisito para todas as fases seguintes) | `core/event_bus.gd` (EventBus real), `core/events/` (padrão de payload), `platform/api/offline_queue.gd` (padrão de fila persistida), `core/config/http_remote_config.gd` (remote config) | `progression/gamification/` (Gamification Engine), payloads novos em `core/events/`, `PendingGameEventsQueue`, serviço de feature flags |
| Fase 28 — Play Games Services v2 e Autenticação | PGS v2 Sign-In + Recall API (opcional) | `progression/profile_repository.gd`, `progression/local_profile_repository.gd`, `progression/remote_profile_repository.gd` | `platform/google_play/play_games_auth_adapter.gd`; habilitar `gradle_build/use_gradle_build=true` em `tools/ci/export_presets.template.cfg` (hoje `false` — bloqueador técnico transversal também às Fases 29, 31, 35) |
| Fase 29 — Sistema de Conquistas e Progression Loop | Achievements API | `progression/achievements/achievement_service.gd`, `progression/xp_service.gd` | Catálogo de 40–60 achievements mapeados a IDs do Play Console, `platform/google_play/play_games_achievements_adapter.gd` |
| Fase 30 — Game Stats e Integração Analytics | Game Stats API | `progression/stats_service.gd`, `platform/analytics/analytics_service.gd`/`remote_analytics.gd`, `gameplay/analytics_bridge.gd` | Pipeline de exportação CSV (`PlayerGameEvent.csv`), `platform/google_play/game_stats_adapter.gd` reportando ≥5 repetitive stats + 1 progression stat |
| Fase 31 — Gamificação Avançada (XP, Quests, Rewards) | Play Games Rewards (GA a partir de 01/09/2026) + Play Points (invite-only) | `progression/challenges/challenge_service.gd`, `progression/challenges/remote_challenge_repository.gd`, `progression/wallet.gd` | `QuestService` server-driven real (substitui o mock `# MOCK-004`), `platform/google_play/rewards_grant_service.gd` (poll `queryPurchasesAsync` via Play Billing Library) |
| Fase 32 — Leaderboards e Social Engagement | Leaderboards API | `progression/leaderboard/leaderboard_repository.gd`, `local_leaderboard_repository.gd`, `remote_leaderboard_repository.gd` | `platform/google_play/play_games_leaderboard_repository.gd` (nova implementação ao lado das existentes, mesmo padrão Local/Remote) |
| Fase 33 — LiveOps (Seasons e Quests Dinâmicas) | Nenhuma API dedicada — "Quests"/"LiveOps" do Google não existe como API própria (`current-requirements.md` §12); mecânica é orquestrada pelo Google sobre Achievements/Game Stats/Rewards já reportados | `progression/season_service.gd` (Fase 25, hoje stub com dado embutido) | Server-Driven Config real para `SeasonService` (substitui o `Dictionary` literal hoje hardcoded), infraestrutura de teste A/B de missões |
| Fase 34 — Sidekick (Integração Completa) | Google Play Games Sidekick | Pipeline de dados das Fases 29/30 (Achievements + Game Stats já reportando); VOLTA publica em AAB (`docs/mobile/android.md`), então ativação é só toggle de Play Console | Nenhum SDK cliente obrigatório; monitoramento do "achievements badge" (100 jogadores únicos/30 dias) e rollout staged 5%→100% recomendado pelo Google |
| Fase 35 — Segurança, Anti-cheat e Play Integrity | Play Integrity API | Validação server-side de score já existente (Fase 15, `docs/backend/anti-cheat.md`), `platform/api/api_client.gd` | `platform/google_play/play_integrity_adapter.gd` (client-side, nonce/requestHash) + endpoint novo no backend Laravel para verificar veredicto |
| Fase 36 — QA Gamificação e Sidekick | Nenhuma nova (validação cruzada de todas as anteriores contra guidelines Level Up) | Suíte GUT existente, `tools/ci/validate-repo.sh` | Matriz de testes offline/troca-de-conta/resync/clear-data, `docs/google-play/level-up-quality.md` |
| Fase 37 — Performance Gamificação e Otimização | Nenhuma nova (mede o custo das integrações acima) | Pipeline de profiling e orçamento da Fase 19 (`docs/performance/performance-budget.md`) | Medição de overhead de `pending_game_events` (batch assíncrono) e de overlays/notificações do Sidekick sobre frame pacing |
| Fase 38 — Release (Rollout Google Play Games) | Todas as superfícies GA acumuladas (PGS v2, Achievements, Game Stats, Leaderboards, Sidekick) | Processo de rollout gradual já ensaiado na Fase 24 (`docs/deployment/release-process.md`) | `docs/google-play/play-console-checklist.md`, plano de rollout com thresholds de rollback específicos para métricas de gamificação |

---

## Referências

- [`docs/google-play/compatibility-audit.md`](./compatibility-audit.md) — estado real do
  repositório (Plano 01), citado nas Seções 1, 2, 4 e 5 deste documento.
- [`docs/google-play/current-requirements.md`](./current-requirements.md) — requisitos oficiais
  vigentes (Plano 02), citado nas Seções 3, 4 e 5 deste documento.
- `docs/architecture/overview.md` — regra de camadas e mecanismos de comunicação, validados na
  Seção 2.
- `apps/mobile/src/core/event_bus.gd` — implementação real do EventBus estendido por este
  desenho.
