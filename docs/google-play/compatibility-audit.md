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
