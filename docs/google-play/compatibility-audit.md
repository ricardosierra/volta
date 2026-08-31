# Auditoria de Compatibilidade — Google Play Games (VOLTA)

> Fase 0 (Discovery) da Fase 26. Este documento registra o estado REAL do repositório, com
> citação de arquivo para cada afirmação, antes de qualquer código de produção ser tocado pelas
> Fases 27-38. Nada aqui foi inferido de memória do que o projeto "deveria" ter — tudo foi lido
> diretamente do código e da documentação em `docs/` no momento da auditoria (2026-08-31).
>
> Seções 1 a 6 escritas pelo Plano 01 (inventário). As seções 7 (registro de riscos
> consolidado) e 8 (parecer go/no-go) são anexadas pelo Plano 03, depois de cruzar este
> inventário com `docs/google-play/current-requirements.md` (Plano 02).

---

## 1. Estado Atual do Projeto

### 1.1 Engine e Build

- **Engine real: Godot 4.7.2** (`apps/mobile/.godot-version` → `4.7.2.stable`;
  `apps/mobile/project.godot` → `config/features=PackedStringArray("4.7", "Mobile")`). Isto é
  uma mudança **recente** — commit `477fd96` ("fix(engine): volta passa a rodar na 4.7.2, a
  mesma dos outros projetos", 2026-08-27) migrou de 4.3 para 4.7.2 porque os scripts de
  `tools/ci/` dependiam de uma instalação local de acaso. **Débito de documentação**: o próprio
  `CLAUDE.md` deste repositório ainda declara "Godot 4.3" no cabeçalho, e
  `docs/mobile/android.md` §"Preparação (GSD 21)" ainda cita "Export template 4.3 stable
  instalado (mesma build do CI)" — ambos desatualizados frente ao `.godot-version` real. Isto
  importa para a integração Google porque plugins/addons Android (Play Games Services v2,
  Sidekick) precisam ser compatíveis com o Godot Android build template da 4.7.x, não da 4.3.
- **Renderer**: `rendering_method="mobile"` (pipeline Vulkan/mobile, com fallback
  Compatibility/GLES3 documentado em `docs/mobile/android.md`), e
  `textures/vram_compression/import_etc2_astc=true` — ambos em `apps/mobile/project.godot`
  `[rendering]`.
- **Estrutura de camadas** (real, confirmada em `docs/architecture/overview.md` §1 e nos
  diretórios de `apps/mobile/src/`): `core/`, `gameplay/`, `territory/`, `runner/`, `ai/`,
  `arena/`, `input/`, `presentation/`, `ui/`, `progression/`, `platform/`. A regra de
  dependência é "uma camada só pode depender de camadas abaixo dela";
  `territory/`/`runner/`/`ai/`/`gameplay/` nunca importam `presentation/` ou `ui/`.
  - **A doc do overview afirma que a violação "é erro de CI (`tools/ci/check_layering.gd`)"
    — esse arquivo NÃO existe no repositório.** A verificação real de camadas está na Seção 7
    de `tools/ci/validate-repo.sh` ("Regra de camadas"), que faz um `grep` por
    `presentation/\|res://src/ui/` dentro de `apps/mobile/src/territory`,
    `apps/mobile/src/runner`, `apps/mobile/src/ai` e `apps/mobile/src/gameplay`. É uma checagem
    textual (não uma análise de import real do Godot), suficiente para o caso atual mas frágil
    a ofuscação (ex.: `load("res://src/" + "ui/x.gd")` escaparia dela).
  - **Não existe hoje nenhuma checagem automatizada de "nenhum `await` no caminho de
    simulação"** (regra 10 de `CLAUDE.md` §3). `tools/ci/validate-repo.sh` não tem nenhuma
    seção sobre `await`; a regra é hoje só convenção/review. Isto é diretamente relevante para
    a integração Google: todo I/O de SDK do Play Games (autenticação, submissão de
    achievement/score, Recall, Saved Games) é assíncrono por natureza, e nada no CI hoje
    impediria um desenvolvedor apressado de colar um `await` dentro de
    `apps/mobile/src/gameplay/match_director.gd` ou de um `*_state.gd` em
    `apps/mobile/src/gameplay/states/`. Registrado como débito na Seção 5.

### 1.2 Event Bus Atual

`apps/mobile/src/core/event_bus.gd` (autoload `EventBus` per `apps/mobile/project.godot`
`[autoload]` — na verdade o autoload registrado ali é só `Bootstrap` e `Log`; `EventBus` é uma
`class_name` comum, instanciada/injetada via `ServiceRegistry`, não um autoload direto) define
**exatamente 4 sinais**, todos primitivos, todos de baixa frequência:

```gdscript
signal config_loaded()
signal config_load_failed(reason: String)
signal save_loaded(result: int)
signal save_written()
```

- `MAX_EMISSIONS_PER_SECOND: int = 5` — em build de debug (`Build.is_debug()`), cada emissão é
  cronometrada em `_emission_timestamps`; passar de 5 emissões/seg do **mesmo** sinal em 1
  segundo dispara `push_warning` (não falha o teste, só avisa).
- **Não existe hoje nenhum evento de domínio de gameplay** — nada como `match_started`,
  `seal_completed`, `achievement_unlocked`, `runner_eliminated` passando pelo EventBus.
  `apps/mobile/src/core/events/README.md` confirma isso textualmente: "Payloads tipados para
  eventos complexos entram aqui conforme necessário (ex.: `MatchStartedEvent` em GSD 06)... Os
  eventos desta fase (`config_loaded`, `save_loaded`, etc... usam apenas tipos primitivos e não
  precisam de payload dedicado ainda", com "**Preenchido em:** conforme a necessidade, a partir
  de GSD 06" — ou seja, o diretório `apps/mobile/src/core/events/` existe mas está vazio de
  eventos de domínio até hoje (GSD 06 já passou faz tempo no numeração antiga; na numeração de
  fase atual isto nunca foi preenchido).
  - Eventos de gameplay que HOJE existem são só **signals locais** ponto-a-ponto, não
    EventBus: `MatchDirector.match_ended(result: MatchResult)` e
    `MatchDirector.final_push_started` (`apps/mobile/src/gameplay/match_director.gd`),
    `EliminationService.runner_eliminated(victim, killer, cause)`
    (`apps/mobile/src/gameplay/elimination_service.gd`),
    `SurgeService.surge_level_changed(runner_id, old_level, new_level)`
    (`apps/mobile/src/gameplay/score/surge_service.gd`),
    `AchievementService.achievement_unlocked(ach: Achievement)`
    (`apps/mobile/src/progression/achievements/achievement_service.gd`),
    `Wallet.balance_changed(type, amount)` (`apps/mobile/src/progression/wallet.gd`),
    `UnlockService.item_unlocked(item_id)` / `unlock_failed(reason)`
    (`apps/mobile/src/progression/cosmetics/unlock_service.gd`).
  - Isto é **o gap central** que a Fase 27 (Gamification Foundation - Eventos de Domínio e
    Integração, per `.planning/ROADMAP.md`) precisa fechar: promover estes signals locais e
    dispersos a eventos de domínio no EventBus (ou um barramento equivalente), para que
    consumidores futuros (Play Games Achievements, Game Stats, Sidekick) possam escutar um
    lugar central em vez de se acoplar a `MatchDirector`, `EliminationService`,
    `AchievementService` etc. individualmente. Documentado como fato observado, não como
    suposição de design.

### 1.3 Loop de Partida e Gameplay

- **`apps/mobile/src/gameplay/match_director.gd`** (`class_name MatchDirector`) é o dono do
  tick físico e das condições de fim de partida:
  - `_physics_process(delta)` roda o `game_state.fsm.tick(delta)` e, só quando
    `game_state.current_state() == GameState.Id.PLAYING`, chama `step(delta)` (que hoje só
    avança `clock.advance()` — o comentário `# FIXED RESOLUTION ORDER (CMBT-007)` lista 8 passos
    planejados: input → movimento → marcar arcos → detectar colisões → resolver seals →
    eliminações → respawn → eventos, mas o corpo real da função só implementa o passo de
    clock) e `update_time(delta)`.
  - `setup_match(mode_config)` monta um `AIScheduler`, uma `Camera2D` fixa em
    `Vector2(540, 960)`, instancia `Runner`s conforme `mode_config.get_meta("bot_count", 0)` com
    um `BotProfile.new()` "Default for now" (comentário no próprio arquivo), e avança a FSM de
    `BOOT`→`MENU`→`LOADING`→`COUNTDOWN` antes do primeiro tick de simulação.
  - `check_end_conditions(grid, score_service)` decide o fim por 3 causas:
    `"DOMINATION"` (`claim_percent >= 0.8`), `"TIME"` (`time_elapsed >= time_limit_sec`,
    desempate por claim depois por score) e `"LAST_MAN_STANDING"` (`active_count <= 1`).
    Emite `signal match_ended(result: MatchResult)` — um signal local, não um evento de
    EventBus (ver 1.2).
- **`apps/mobile/src/gameplay/game_state.gd`** (`class_name GameState`) monta a FSM real via
  `StateMachine` com os 7 estados de `apps/mobile/src/gameplay/states/`: `BootState`,
  `MenuState`, `LoadingState`, `CountdownState`, `PlayingState`, `PausedState`, `ResultsState`
  (um arquivo cada, confirmando `docs/architecture/overview.md` "um tipo por arquivo").
  Transições declaradas: `BOOT→MENU→LOADING→COUNTDOWN→PLAYING⇄PAUSED→RESULTS→{MENU,LOADING}`.
  Cada estado de `apps/mobile/src/gameplay/states/*.gd` hoje só loga a entrada
  (`Log.info(Log.Category.GAMEPLAY, "Entered X state")`) e, no caso de `CountdownState`, conta
  3 segundos e pede a transição para `PLAYING`; `PausedState` também pausa/despausa a
  `SceneTree`.
- **`apps/mobile/src/gameplay/score/score_service.gd`** (`class_name ScoreService`) calcula
  pontuação por `runner_id` a partir de 3 fontes, todas somadas em `_recalc`:
  `territory_points` (via `handle_seal`, com `base_seal_mult`/`steal_mult` lidos de
  `config.get_meta(...)` — não hardcoded, per regra 4 de `CLAUDE.md`), `break_points` (via
  `handle_break`, `config.get_meta("break_base", 500)`) e `survival_points` (via
  `handle_survival_tick`, `config.get_meta("survival_tick", 1)`, só para runners não
  `ELIMINATED`).
- **`apps/mobile/src/gameplay/score/surge_service.gd`** (`class_name SurgeService`) mantém
  `runner_surge: Dictionary` (id → nível float), com `add_surge`, decaimento por `tick(delta)`
  (`config.get_meta("decay_rate_per_sec", 0.5)`), `get_multiplier` (aplicado em
  `ScoreService.handle_seal` como `surge_mult`) e `reset_surge`. Emite
  `surge_level_changed(runner_id, old_level, new_level)` só quando o nível inteiro muda.
- **`apps/mobile/src/gameplay/modes/match_rules.gd`** (`class_name MatchRules`, `extends
  Resource`) é o modo como **dado**, não código: `id`, `name`, `time_limit_sec`, `bot_count`,
  `player_respawn`, `respawn_delay_sec`, `win_condition` (enum `TIME`/`DOMINATION`/`SURVIVAL`/
  `ENDLESS`), `domination_target`, `rules: Array[Script]` — confere a afirmação de
  `docs/architecture/overview.md` de que modos são configuração, não branch de código.
- **`apps/mobile/src/gameplay/powerups/power_up_service.gd`** (`class_name PowerUpService`)
  mantém `active_effects: Dictionary` (`runner_id → PowerUpEffect`), com `apply_effect`
  (expira o efeito anterior antes de aplicar o novo) e `tick(delta, runners)` (chama
  `on_tick`/`on_expire` do efeito ativo por runner).
- **`apps/mobile/src/gameplay/elimination_service.gd`** (`class_name EliminationService`,
  `extends RefCounted`) resolve duas causas de eliminação — `handle_break` e `handle_squeeze`
  — ambas liberando o claim no `TerritoryGrid`, limpando o `ArcTracker` e emitindo
  `runner_eliminated(victim, killer, cause)`.

**Por que isto importa para a Fase 26+**: toda integração de Google Play Games (I/O de
rede/SDK — autenticação, submissão de Achievement, Leaderboard, Saved Games) é inerentemente
assíncrona, e **nunca pode entrar** em `territory/`, `runner/`, `ai/` ou `gameplay/` — só pode
ser disparada a partir de uma camada acima (ex.: `presentation/` ou um serviço em `platform/`)
reagindo a um evento de domínio que ainda não existe (Seção 1.2). O loop de partida real hoje
não tem nenhum ponto de saída assíncrono; `step(delta)` e `_physics_process` são 100% síncronos.

---

## 2. Gamificação Já Existente (Fases 10, 11, 14, 18)

### 2.1 Progressão (Perfil, XP, Stats, Season)

- **`apps/mobile/src/progression/profile.gd`** (`class_name Profile`, `extends RefCounted`) é
  um bag de dados puro: `player_id`, `nickname`, `avatar_id`, `frame_id`, `title_id`, `xp`.
  **Não há campo de conta Google** (`google_id`, `play_games_player_id` ou equivalente) — ver
  Seção 5.
- **`apps/mobile/src/progression/xp_service.gd`** (`class_name XpService`) implementa a curva
  de nível declarada em `docs/design/progression.md` §1
  (`xp_for_level(n) = round(100 × n^1,35)`) como `XP_MULT = 100.0` / `XP_EXPONENT = 1.35`, com
  `calculate_level(xp)` (inverso da fórmula) e `add_xp(profile, amount)`. `_on_level_up(new_lvl)`
  hoje é um método vazio com o comentário `# Emit particles, unlock frames` — **o level-up não
  dispara nenhum evento nem efeito ainda**, nem local nem de EventBus.
- **`apps/mobile/src/progression/stats_service.gd`** (`class_name StatsService`) rastreia
  `total_kills`, `total_deaths`, `total_matches`, `total_wins`, `total_captures`,
  `playtime_seconds`, com `get_kd_ratio()` e `get_winrate()`. É um subconjunto pequeno da lista
  completa de estatísticas descrita em `docs/design/progression.md` §2 (que também cita "maior
  Seal único", "maior Surge atingido", "sequência atual/melhor de vitórias", "Squeezes",
  "Cuts", "distância percorrida" — **nenhum desses campos existe hoje em `StatsService`**, é
  débito frente à própria spec de design, relevante porque Game Stats (Fase 30) provavelmente
  vai querer relatar exatamente esse conjunto mais rico).
- **`apps/mobile/src/progression/season_service.gd`** (`class_name SeasonService`) hoje é um
  **stub com dado embutido no código**: `fetch_season_config()` não faz nenhuma chamada de
  rede, só atribui um `Dictionary` literal (`"season_1"`, `"Neon Genesis"`, `free_track` /
  `premium_track` fixos) a `current_season`. Não há season pass real, nem persistência, nem
  cálculo de progresso dentro da season.

### 2.2 Conquistas e Desafios

- **`apps/mobile/src/progression/achievements/achievement_service.gd`** (`class_name
  AchievementService`) mantém `unlocked_ids: Array[String]` e `check_stats(stats,
  all_achievements)`, que percorre uma lista de `Achievement` e resolve o critério de
  desbloqueio por um `match ach.id` **hardcoded** com só 3 casos reais: `"first_blood"`
  (`stats.total_kills > 0`), `"centurion"` (`stats.total_matches >= 100`), `"dominator"`
  (`stats.total_wins >= 10`) — qualquer outro `id` de `Achievement` passado nunca desbloqueia
  (cai no `match` sem default, `unlocked` continua `false`). Emite
  `achievement_unlocked(ach: Achievement)` como signal local.
- **`apps/mobile/src/progression/challenges/challenge_service.gd`** (`class_name
  ChallengeService`) gera 3 desafios diários por `Time.get_datetime_dict_from_system()["day"]`,
  com o próprio código marcado `# MOCK-004: Will be remote in GSD 16` (confirmado como mock
  rastreado em `.gsd/BACKLOG.md`, ver Seção 4). A geração hoje é literalmente `"Mock Daily " +
  str(i+1)` com `target` aleatório — não usa o pool de desafios com peso descrito em
  `docs/design/progression.md` §4 (que lista 9 tipos de desafio concretos, ex. "Capture 25% do
  mapa em uma partida"). Existe também `apps/mobile/src/progression/challenges/
  remote_challenge_repository.gd` (não lido em profundidade neste plano, listado aqui porque
  seu nome confirma que o padrão Local/Remote de `docs/architecture/networking.md` §1 já foi
  iniciado para `ChallengeRepository`, mesmo com `ChallengeService` ainda mockado).

### 2.3 Cosméticos e Carteira (Wallet)

- **`apps/mobile/src/progression/cosmetics/catalog.gd`** (`class_name Catalog`) tem
  `load_all(directory)` com o comentário `# Mock loading since actual scanning in GDScript
  needs EditorFileSystem or fixed arrays` e corpo vazio (`pass`) — **o catálogo de cosméticos
  não carrega nada em runtime hoje**; `get_item(id)` só consulta o `Dictionary items` interno,
  que nunca é populado por `load_all`.
- **`apps/mobile/src/progression/cosmetics/unlock_service.gd`** (`class_name UnlockService`)
  implementa `attempt_purchase(item_id)` contra `Inventory` + `Wallet` + `Catalog`: bloqueia
  item já possuído (`unlock_failed("ALREADY_OWNED")`), gasta `Sparks` via `wallet.spend_sparks`
  se `item.price_sparks > 0`, mas o ramo de `item.price_prisms > 0` está com o comentário
  `# Prisms logic similar` seguido de `pass` — **compra com moeda premium (Prisms) não está
  implementada**, só a de moeda soft (Sparks).
- **`apps/mobile/src/progression/wallet.gd`** (`class_name Wallet`) mantém dois saldos inteiros
  simples, `sparks` e `prisms`, com `add_sparks`/`spend_sparks`/`add_prisms` e um único signal
  `balance_changed(type: String, amount: int)`. Confere as duas moedas de
  `docs/design/economy.md` (Sparks = soft, Prisms = hard), mas os preços de
  `docs/design/economy.md` ("Common Avatar: 1.500 Sparks" etc.) não estão referenciados em
  nenhum `.tres` de config lido neste plano — não foi possível confirmar onde esses números
  moram hoje no código.
- **`apps/mobile/src/progression/cosmetics/inventory.gd`** (`class_name Inventory`, `extends
  RefCounted`) é uma lista simples `owned_ids: Array[String]` com `has_item`/`add_item`.

### 2.4 Leaderboards e Cloud Save

- **Já existe o padrão Local/Remote** descrito em `docs/architecture/networking.md` §1 para
  leaderboard: `apps/mobile/src/progression/leaderboard/leaderboard_repository.gd` (`class_name
  LeaderboardRepository`, `extends RefCounted`) é a interface-base, e traz literalmente o
  comentário `## MOCK / Replacement Phase: GSD 16 / Replacement Task: ONLN-003` — este é o
  **MOCK-001** de `.gsd/BACKLOG.md`. `save_score`/`get_top_scores` da interface-base são no-ops
  (`pass` / `return []`).
  - `apps/mobile/src/progression/leaderboard/local_leaderboard_repository.gd` (`class_name
    LocalLeaderboardRepository`, `extends LeaderboardRepository`) implementa um cache em
    memória (`_cache: Dictionary`) por `mode`, ordenado por score decrescente, truncado em 20
    entradas — com o comentário `# In a full implementation, persist to disk here via
    SaveService`, ou seja, **hoje não persiste em disco**, perde o placar ao fechar o app.
  - `apps/mobile/src/progression/leaderboard/remote_leaderboard_repository.gd` (`class_name
    RemoteLeaderboardRepository`, `extends LeaderboardRepository`) já fala com `ApiClient`
    (`get_leaderboard`/`submit_score` batendo em `/leaderboards/{id}` e `/matches`, alinhado com
    as rotas de `docs/backend/api-design.md`), mas `get_leaderboard` retorna `[]` de imediato e
    só popula um `cache` depois via callback assíncrono não mostrado neste arquivo — condizente
    com o padrão "nunca bloqueia o gameplay" de `docs/architecture/networking.md` §1.
  - **Isto é relevante porque Play Games Leaderboards (Fase 32) seguirá exatamente este mesmo
    padrão de repositório**: uma nova implementação (`PlayGamesLeaderboardRepository` ou
    equivalente) ao lado de `Local*`/`Remote*`, registrada no `ServiceRegistry` do `Bootstrap`
    (`apps/mobile/src/core/bootstrap.gd`), sem tocar no gameplay que a consome.
- **`apps/mobile/src/progression/cloud_save_service.gd`** (`class_name CloudSaveService`) é
  fino: `sync_up(state)` faz `POST /save`, `sync_down()` faz `GET /save`, ambos via `ApiClient`
  — bate com as rotas `GET/PUT /save` de `docs/backend/api-design.md`. Não há hoje resolução de
  conflito nem versionamento (`schema_version`/`updated_at`) implementados neste arquivo, apesar
  de a rota de backend já prever isso. Confirmar contra
  `docs/google-play/current-requirements.md` (quando existir) qual fase consome isso via Saved
  Games API — no momento desta tarefa esse documento ainda não existe (produzido em paralelo
  pelo Plano 02).
- **`apps/mobile/src/progression/profile_repository.gd`** (`class_name ProfileRepository`,
  `extends RefCounted`) é a interface-base (`get_profile()`/`save_profile()`, ambos no-op).
  - `apps/mobile/src/progression/local_profile_repository.gd` (`class_name
    LocalProfileRepository`) gera um perfil "convidado" em memória (`player_id =
    "local_user_1"`, `nickname = "Guest_" + str(randi() % 9999)`) na primeira chamada de
    `get_profile()`; é o serviço realmente registrado hoje em
    `apps/mobile/src/core/bootstrap.gd` (`"profile_repo": LocalProfileRepository.new()`).
  - `apps/mobile/src/progression/remote_profile_repository.gd` (`class_name
    RemoteProfileRepository`) chama `local_cache.load_profile()` dentro de `load_profile()` —
    **`LocalProfileRepository` não define nenhum método `load_profile()`, só `get_profile()`**;
    isto é um bug real de nomenclatura já existente no código hoje (não corrigido por este
    plano de auditoria, per regra de escopo — registrado como débito na Seção 5).

### 2.5 Analytics, API e Fila Offline

- **`apps/mobile/src/platform/analytics/analytics_service.gd`** (`class_name AnalyticsService`)
  é a interface (`log_event`, `set_user_property`, ambos vazios), conforme
  `docs/product/analytics-plan.md` ("o gameplay nunca chama um SDK... emite eventos numa
  interface própria").
  - `apps/mobile/src/platform/analytics/noop_analytics.gd` (`class_name NoopAnalytics`,
    `extends AnalyticsService`) é o **MOCK-002** de `.gsd/BACKLOG.md` (comentário
    `# MOCK-002: Replaced in GSD 18` no próprio arquivo); em debug builds (`OS.is_debug_build()`)
    só imprime no console.
  - `apps/mobile/src/platform/analytics/remote_analytics.gd` (`class_name RemoteAnalytics`)
    faz batch em memória (`batch: Array[Dictionary]`), envia a cada 10 eventos via `POST
    /telemetry` (bate com a rota de `docs/backend/api-design.md`), e respeita um flag
    `consent_given` (mas **não persiste a escolha de opt-out** — é uma var em memória, sem
    ligação visível com `Settings > Privacy` descrito em `docs/product/analytics-plan.md`
    §Privacidade).
  - **Nenhum dos eventos do catálogo v1** de `docs/product/analytics-plan.md` (`app_started`,
    `game_started`, `game_finished`, `territory_captured`, `player_eliminated`, etc.) é emitido
    pelos arquivos lidos nesta auditoria — só `apps/mobile/src/gameplay/analytics_bridge.gd`
    (`class_name AnalyticsBridge`) emite 3 eventos reais: `match_started` (com `mode`),
    `match_ended` (com `cause`, `winner_id`, `duration`) e `runner_eliminated` (com `victim`,
    `killer`, `cause`) — nomes e propriedades **diferentes** dos nomes do plano de analytics
    (`game_started`/`game_finished`/`player_eliminated`), o que é uma divergência real entre
    design e implementação (registrada como débito na Seção 5, relevante para Game Stats na
    Fase 30, que provavelmente vai querer reaproveitar/mapear esse pipeline).
- **`apps/mobile/src/platform/api/api_client.gd`** (`class_name ApiClient`) usa `HTTPRequest`
  puro do Godot (não uma lib HTTP terceira), monta headers com `Authorization: Bearer` e
  `Idempotency-Key` quando fornecidos (alinhado com `docs/backend/api-design.md` §Princípios
  "Escritas são idempotentes"), mas **não implementa timeout nem retry com backoff** descritos
  em `docs/architecture/networking.md` §2 ("Timeout curto (padrão 8 s), 2 retries com backoff
  exponencial e jitter") — nada disso aparece em `post()`/`get_data()`/`_on_request_completed()`.
- **`apps/mobile/src/platform/api/offline_queue.gd`** (`class_name OfflineQueue`) persiste uma
  fila de escritas pendentes (`endpoint`, `method`, `payload`, `idempotency_key`) em
  `user://offline_queue.json`, carregada em `_ready()` e salva a cada `enqueue()`. **Não tem
  nenhum mecanismo de drenagem/retry visível neste arquivo** (nenhum método `flush`/`drain`/
  `process_queue`) — os itens só entram, nunca são explicitamente removidos ou reenviados por
  este arquivo.
- **`apps/mobile/src/network/network_transport.gd`** (`class_name NetworkTransport`) é sobre
  multiplayer ENet (`start_server`/`start_client` com `ENetMultiplayerPeer`), **não** sobre a
  API HTTP — não tem relação direta com Google Play Games, citado aqui só porque estava na
  lista de leitura da tarefa e para deixar claro que não é o mesmo sistema que `ApiClient`.

---

## 3. Ativos Reaproveitáveis para a Integração Google

| Sistema existente | Arquivo | Reaproveitável para | Observação |
|---|---|---|---|
| `AchievementService` | `apps/mobile/src/progression/achievements/achievement_service.gd` | Sincronização de Play Games Achievements (Fase 29) | Hoje só resolve 3 IDs hardcoded via `match`; precisa de fonte de dados extensível antes de mapear N conquistas para IDs de Achievement do Play Console |
| `XpService` / `StatsService` | `apps/mobile/src/progression/xp_service.gd`, `apps/mobile/src/progression/stats_service.gd` | Progression Stat / Repetitive Stats de Game Stats (Fase 30) | `StatsService` cobre só 6 dos ~14 campos listados em `docs/design/progression.md` §2; Game Stats provavelmente exige o conjunto completo |
| `leaderboard/*` (`LeaderboardRepository`, `LocalLeaderboardRepository`, `RemoteLeaderboardRepository`) | `apps/mobile/src/progression/leaderboard/` | Play Games Leaderboards (Fase 32) | Padrão Local/Remote já pronto (per `docs/architecture/networking.md` §1); é o MOCK-001 de `.gsd/BACKLOG.md`, com destino de substituição já apontado para a fase de rede (GSD 16 na numeração antiga) |
| `CloudSaveService` | `apps/mobile/src/progression/cloud_save_service.gd` | Saved Games API — confirmar contra `docs/google-play/current-requirements.md` no Plano 03 (documento ainda não existe no momento desta tarefa) | Hoje só `POST /save` / `GET /save` sem resolução de conflito nem `schema_version` local |
| `OfflineQueue` | `apps/mobile/src/platform/api/offline_queue.gd` | Padrão de fila para `pending_game_events` (Fase 27) | Persiste em `user://offline_queue.json`, mas não tem drenagem/retry implementados hoje — reaproveitar a estrutura de persistência, não o fluxo completo |
| `AnalyticsService` / `RemoteAnalytics` / `AnalyticsBridge` | `apps/mobile/src/platform/analytics/analytics_service.gd`, `apps/mobile/src/platform/analytics/remote_analytics.gd`, `apps/mobile/src/gameplay/analytics_bridge.gd` | Pipeline de telemetria reaproveitável para reportar Game Stats (Fase 30) | Nomes de evento reais (`match_started`/`match_ended`/`runner_eliminated`) divergem do catálogo v1 de `docs/product/analytics-plan.md` (`game_started`/`game_finished`/`player_eliminated`) — precisa reconciliar antes de usar como fonte única para Game Stats |
| `ProfileRepository` / `LocalProfileRepository` / `RemoteProfileRepository` | `apps/mobile/src/progression/profile_repository.gd`, `apps/mobile/src/progression/local_profile_repository.gd`, `apps/mobile/src/progression/remote_profile_repository.gd` | Vínculo de `player_id` local com `play_games_player_id` (Fase 28) | Mesmo padrão Local/Remote; `Profile` não tem campo de conta Google hoje (ver Seção 2.1) |
| `Wallet` / `UnlockService` / `Catalog` | `apps/mobile/src/progression/wallet.gd`, `apps/mobile/src/progression/cosmetics/unlock_service.gd`, `apps/mobile/src/progression/cosmetics/catalog.gd` | Rewards do Play Games (moeda/cosmético como recompensa de quest, Fase 31) | `Catalog.load_all()` é hoje um `pass` vazio (mock não rastreado em `.gsd/BACKLOG.md`) — carregamento real de catálogo é pré-requisito antes de conceder rewards por item |
