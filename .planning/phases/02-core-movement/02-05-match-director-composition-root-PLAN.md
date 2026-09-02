---
phase: 02-core-movement
plan: 05
type: execute
wave: 2
depends_on: ["02-01", "02-02", "02-03", "02-04"]
files_modified:
  - apps/mobile/src/gameplay/match_director.gd
  - apps/mobile/src/root.gd
  - apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd
  - apps/mobile/tests/integration/test_runner_presentation_wiring.gd
  - apps/mobile/tests/gameplay/test_headless_movement.gd
  - apps/mobile/tests/integration/test_match_lifecycle.gd
  - apps/mobile/tests/integration/test_pause_freeze.gd
autonomous: true
requirements:
  - MOV-01
  - MOV-02
  - MOV-07
must_haves:
  truths:
    - "Ao tocar PLAY no jogo real, existe um Runner do jogador (não só bots) que se move a cada tick de 60 Hz, girando e avançando com os números de RunnerBalance"
    - "O Runner do jogador recebe direção SOMENTE de InputRouter.poll_direction() — nenhum InputEvent chega a ele"
    - "A mesma configuração de partida produz o mesmo estado final em 10 execuções headless de 600 ticks, sem nenhum nó visual instanciado"
    - "GameState.Id.PAUSED congela posição, contador de tick e tempo decorrido — provado chamando _physics_process diretamente, sem depender de SceneTree.paused"
    - "gameplay/match_director.gd não cria mais nenhum Camera2D cru — a câmera é composta em root.gd"
  artifacts:
    - path: "apps/mobile/src/gameplay/match_director.gd"
      provides: "configure(config, arena_definition, router), player_runner real, step() com input->movimento->contenção de arena, sem Camera2D cru"
      contains: "func configure(config: ConfigService"
    - path: "apps/mobile/src/root.gd"
      provides: "composition root: CanvasLayer para UI, ConfigService resolvido do Bootstrap, InputRouter e GameCamera reais instanciados e ligados"
      contains: "CanvasLayer"
  key_links:
    - from: "apps/mobile/src/root.gd"
      to: "apps/mobile/src/gameplay/match_director.gd"
      via: "_match_director.configure(_config, arena_definition, _input_router) antes de setup_match()"
      pattern: "\\.configure\\("
    - from: "apps/mobile/src/gameplay/match_director.gd"
      to: "apps/mobile/src/input/input_router.gd"
      via: "step() chama input_router.poll_direction(delta) e aplica em player_runner.set_desired_direction()"
      pattern: "input_router.poll_direction"
    - from: "apps/mobile/src/root.gd"
      to: "apps/mobile/src/presentation/camera/game_camera.gd"
      via: "GameCamera.setup(_config.camera(), _match_director.arena) + target_visual = view do jogador"
      pattern: "game_camera.setup"
---

<objective>
Este é o plano de integração central da fase — onde os quatro planos da Wave 1 (Runner/config,
FSM/Arena, InputRouter/Buffer, RunnerView/GameCamera) se encontram dentro do jogo real.

**O problema, exatamente como a auditoria de 2026-09-02 descreveu:** `MatchDirector.step()`
hoje só faz `clock.advance()` — as etapas "input → movimento → ..." existem apenas como
comentário. `setup_match()` cria só Runners de IA (com um `BotBrain` que nunca é ligado, porque
`AIScheduler.tick()` exige um `TerritoryGrid` que só existe na Fase 3 — não tente ligá-lo aqui,
é fora de escopo). **Não existe nenhum Runner do jogador** na simulação: o jogador de verdade é
inteiramente simulado dentro de `MatchScreen` (o "loop de brinquedo" que o Plano 02-06 remove).
`setup_match()` também cria um `Camera2D` cru dentro de `gameplay/` — uma violação de camada.

Purpose: fazer `MatchDirector` criar e mover um Runner de jogador de verdade, alimentado
exclusivamente por `InputRouter` (com o buffer do Plano 02-03), contido pela `Arena` do Plano
02-02, com velocidade/giro de `RunnerBalance` (Plano 02-01) — e fazer `root.gd`, o composition
root, ligar tudo isso mais a apresentação (`RunnerView`/`GameCamera` do Plano 02-04) sem que
`gameplay/` conheça nenhuma dessas peças de apresentação.

**Descoberta importante:** hoje o composition root (`root.gd`) e toda a UI (`ScreenStack`,
`MatchScreen`) vivem soltos, sem `CanvasLayer`. Assim que uma `Camera2D` de verdade existir e
começar a se mover/dar zoom, ela afeta TODOS os `CanvasItem` do canvas base — incluindo a UI
inteira (botões, HUD), que ficaria panando/dando zoom junto com o jogo. Isso nunca apareceu
antes porque nenhuma câmera real jamais foi instanciada. Este plano corrige isso colocando a UI
dentro de um `CanvasLayer` (que ignora a transformação de câmera do canvas base), deixando
`GameCamera` e as `RunnerView`s no canvas base, onde uma câmera de verdade deve viver.

Output: `MatchDirector.step()` executando de verdade; um Runner de jogador real na simulação;
`root.gd` como composition root completo desta fase (config + input + câmera + apresentação);
os testes de alcançabilidade, determinismo e congelamento que a re-execução exige.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@CLAUDE.md
@.planning/phases/02-core-movement/02-CONTEXT.md
@.planning/ROADMAP.md
@docs/decisions/ADR-0006-movement-model.md
@docs/decisions/ADR-0014-simulation-tick-model.md
@docs/architecture/overview.md
</context>

<interfaces>
Depois dos 4 planos da Wave 1, os contratos que este plano consome são:

    # Runner (apps/mobile/src/runner/runner.gd) — Plano 02-01
    func _init(runner_id: int, start_pos: Vector2, start_dir: Vector2, balance: RunnerBalance = null) -> void: ...

    # ConfigService (apps/mobile/src/core/config/config_service.gd) — já existia, registrado no Bootstrap pelo Plano 02-01
    func runner() -> RunnerBalance: ...
    func camera() -> CameraBalance: ...
    # Resolvível via: Bootstrap.registry.resolve("config") as ConfigService

    # ArenaDefinition / Arena (apps/mobile/src/arena/) — Plano 02-02
    class Arena:
    	func _init(def: ArenaDefinition) -> void: ...  # limits = Rect2(ZERO, def.get_pixel_size())
    	var limits: Rect2
    	func resolve_boundaries(runner_state: RunnerState) -> void: ...
    # apps/mobile/resources/arenas/open_field.tres — 2048x2048, 1 spawn point em (1024,1024)

    # InputRouter (apps/mobile/src/input/input_router.gd) — Plano 02-03
    func _init() -> void: ...  # já cria driver + buffer, utilizável sem _ready()
    func poll_direction(delta: float) -> Vector2: ...  # buffer + fallback contínuo do driver
    func set_driver(new_driver: InputDriver) -> void: ...

    # RunnerView / RunnerViewSpawner (apps/mobile/src/presentation/) — Plano 02-04
    class RunnerView extends InterpolatedVisual:
    	var runner: Runner   # setado por RunnerViewSpawner._on_runner_spawned
    # RunnerViewSpawner._on_runner_spawned já seta view.runner = runner e view.global_position

    # GameCamera (apps/mobile/src/presentation/camera/game_camera.gd) — Plano 02-04
    func setup(balance: CameraBalance, game_arena: Arena) -> void: ...
    var target_visual: InterpolatedVisual   # setado externamente pelo composition root

Estado ATUAL de `apps/mobile/src/gameplay/match_director.gd` (arquivo inteiro, 92 linhas —
leia-o também com o Read tool antes de editar, esta cópia é para referência rápida):

    class_name MatchDirector
    extends Node

    var game_state: GameState
    var clock: SimulationClock
    var resolver: CollisionResolver
    var elimination: EliminationService

    func _ready() -> void:
    	game_state = GameState.new(self)
    	add_child(game_state)
    	clock = SimulationClock.new(0)
    	resolver = CollisionResolver.new()
    	elimination = EliminationService.new()
    	Engine.max_fps = DisplayServer.screen_get_refresh_rate()
    	if Engine.max_fps == -1:
    		Engine.max_fps = 60

    func step(delta: float) -> void:
    	# FIXED RESOLUTION ORDER (CMBT-007)
    	# 1. input  2. movement  3. mark arcs  4. detect collisions  5. resolve seals
    	# 6. process eliminations  7. respawn  8. events
    	clock.advance()

    var ai_scheduler: AIScheduler
    var runners: Array[Runner] = []
    signal runner_spawned(runner: Runner)

    func setup_match(mode_config: Resource) -> void:
    	ai_scheduler = AIScheduler.new()
    	add_child(ai_scheduler)

    	var cam := Camera2D.new()
    	cam.position = Vector2(540, 960) # Center of screen
    	add_child(cam)

    	var bot_count: int = mode_config.get_meta("bot_count", 0)
    	for i in range(bot_count):
    		var r := Runner.new(i + 1, Vector2(100 + i*50, 100), Vector2.UP)
    		runners.append(r)
    		var profile := BotProfile.new() # Default for now
    		var brain := BotBrain.new(profile)
    		ai_scheduler.register_bot(r, brain)
    		runner_spawned.emit(r)

    	if game_state and game_state.fsm:
    		if game_state.current_state() == GameState.Id.BOOT:
    			game_state.request_transition(GameState.Id.MENU)
    		if game_state.current_state() == GameState.Id.MENU:
    			game_state.request_transition(GameState.Id.LOADING)
    		if game_state.current_state() == GameState.Id.LOADING:
    			game_state.request_transition(GameState.Id.COUNTDOWN)

    var time_limit_sec: float = 180.0
    var time_elapsed: float = 0.0
    var is_final_push: bool = false
    signal final_push_started

    func update_time(delta: float) -> void:
    	if game_state.current_state() == GameState.Id.PLAYING:
    		time_elapsed += delta
    		var remaining: float = time_limit_sec - time_elapsed
    		if remaining <= 30.0 and not is_final_push:
    			is_final_push = true
    			final_push_started.emit()

    signal match_ended(result: MatchResult)

    func check_end_conditions(grid: TerritoryGrid, score_service: ScoreService) -> void:
    	# ... (não muda — território/score são fases 3/6, esta função continua sem chamador)

    func _end_match(winner: int, placements: Array, cause: String) -> void:
    	# ... (não muda)

    func _physics_process(delta: float) -> void:
    	if not game_state or not game_state.fsm:
    		return
    	game_state.fsm.tick(delta)
    	if game_state.current_state() == GameState.Id.PLAYING:
    		step(delta)
    		update_time(delta)

Estado ATUAL de `apps/mobile/src/root.gd` (arquivo inteiro, 47 linhas):

    extends Control
    var screen_stack: ScreenStack
    var _match_director: MatchDirector
    var _runner_view_spawner: RunnerViewSpawner

    func _ready() -> void:
    	screen_stack = ScreenStack.new()
    	add_child(screen_stack)
    	screen_stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	var splash := SplashScreen.new()
    	splash.finished.connect(_show_main_menu)
    	screen_stack.push(splash)

    func _show_main_menu() -> void:
    	var menu := MainMenuScreen.new()
    	menu.play_requested.connect(_start_match)
    	screen_stack.replace_root(menu)

    func _start_match() -> void:
    	if is_instance_valid(_match_director):
    		return
    	var match_screen := MatchScreen.new()
    	match_screen.exit_requested.connect(_return_to_menu)
    	screen_stack.push(match_screen)
    	_match_director = MatchDirector.new()
    	add_child(_match_director)
    	_runner_view_spawner = RunnerViewSpawner.new()
    	add_child(_runner_view_spawner)
    	_runner_view_spawner.watch(_match_director)
    	var config := Resource.new()
    	config.set_meta("bot_count", 3)
    	_match_director.setup_match(config)
    	match_screen.set_bot_count(3)
    	set_process(true)

    func _return_to_menu() -> void:
    	if is_instance_valid(_match_director):
    		_match_director.queue_free()
    		_match_director = null
    	if is_instance_valid(_runner_view_spawner):
    		_runner_view_spawner.queue_free()
    		_runner_view_spawner = null
    	if screen_stack and screen_stack.can_pop():
    		screen_stack.pop()
</interfaces>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: MatchDirector — Runner do jogador real, step() completo, sem Camera2D cru</name>
  <files>apps/mobile/src/gameplay/match_director.gd, apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd, apps/mobile/tests/gameplay/test_headless_movement.gd</files>
  <read_first>
    - apps/mobile/src/gameplay/match_director.gd (arquivo inteiro — veja o bloco `<interfaces>` acima para o estado atual completo)
    - apps/mobile/src/runner/runner.gd, apps/mobile/src/arena/arena.gd, apps/mobile/src/input/input_router.gd (contratos pós Wave 1, no bloco `<interfaces>` acima)
    - apps/mobile/src/gameplay/game_state.gd (current_state(), request_transition — não muda)
    - apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd (o teste que este plano precisa ATUALIZAR — as contagens mudam de bot_count para bot_count+1)
    - .planning/phases/02-core-movement/02-CONTEXT.md, bloco `<reexecution>` (o que "MatchDirector.step() executa input → movimento a 60 Hz fixo... zero literal de gameplay" significa concretamente)
  </read_first>
  <behavior>
    - `configure(config, arena_definition, router)` monta `_runner_balance` (de `config.runner()`), `arena` (de `Arena.new(arena_definition)`) e guarda `router` — chamável antes de `setup_match()`
    - `setup_match()` cria SEMPRE um Runner de jogador (id 0, sem `BotBrain`) além dos `bot_count` bots — a ordem é: jogador primeiro, depois os bots, cada um emitindo `runner_spawned`
    - Sem `configure()` ter sido chamado (compatibilidade com os testes existentes que só chamam `setup_match()` direto), o jogador nasce em `Vector2(540, 960)` como antes, e `_runner_balance` cai no `RunnerBalance.new()` default — nada quebra
    - `step(delta)` aplica `input_router.poll_direction(delta)` como `desired_direction` do jogador ANTES de mover qualquer Runner; todos os Runners (jogador e bots) são avançados por `tick(delta)`; se `arena` existe, cada um é contido por `arena.resolve_boundaries()`; só então `clock.advance()`
    - `setup_match()` não cria mais nenhum `Camera2D`
  </behavior>
  <action>
    Reescreva `apps/mobile/src/gameplay/match_director.gd` por inteiro (o arquivo atual está
    no bloco `<interfaces>` acima; troque por esta versão, que preserva
    `check_end_conditions`/`_end_match`/`update_time`/`_physics_process` sem alteração de
    comportamento):

    ```gdscript
    class_name MatchDirector
    extends Node

    var game_state: GameState
    var clock: SimulationClock
    var resolver: CollisionResolver
    var elimination: EliminationService
    var ai_scheduler: AIScheduler
    var runners: Array[Runner] = []
    var player_runner: Runner
    var arena: Arena
    var input_router: InputRouter

    var _runner_balance: RunnerBalance = RunnerBalance.new()

    ## Emitido quando um novo Runner passa a existir na partida. gameplay/ não conhece a
    ## camada de apresentação (CLAUDE.md §5, docs/architecture/overview.md §1) — quem cria a
    ## RunnerView é RunnerViewSpawner, ouvindo este sinal (ver runner_view_spawner.gd).
    signal runner_spawned(runner: Runner)
    signal match_ended(result: MatchResult)
    signal final_push_started

    var time_limit_sec: float = 180.0
    var time_elapsed: float = 0.0
    var is_final_push: bool = false


    func _ready() -> void:
    	game_state = GameState.new(self)
    	add_child(game_state)
    	clock = SimulationClock.new(0)
    	resolver = CollisionResolver.new()
    	elimination = EliminationService.new()
    	Engine.max_fps = DisplayServer.screen_get_refresh_rate()
    	if Engine.max_fps == -1:
    		Engine.max_fps = 60


    ## Injeção de dependência do composition root (root.gd) — nunca resolvida internamente
    ## por um service locator global (docs/architecture/overview.md §4). Chame antes de
    ## setup_match(). Sem chamar, os defaults abaixo mantêm o comportamento anterior a este
    ## plano (compatibilidade com testes que só chamam setup_match() direto).
    func configure(config: ConfigService, arena_definition: ArenaDefinition, router: InputRouter) -> void:
    	if config:
    		_runner_balance = config.runner()
    	if arena_definition:
    		arena = Arena.new(arena_definition)
    	input_router = router


    func step(delta: float) -> void:
    	# FIXED RESOLUTION ORDER (CMBT-007)
    	# 1. input
    	# 2. movement
    	# 3. mark arcs        (Fase 3)
    	# 4. detect collisions (Fase 4)
    	# 5. resolve seals     (Fase 3)
    	# 6. process eliminations (Fase 4)
    	# 7. respawn           (Fase 4)
    	# 8. events

    	if player_runner and input_router:
    		player_runner.set_desired_direction(input_router.poll_direction(delta))

    	for r in runners:
    		r.tick(delta)
    		if arena:
    			arena.resolve_boundaries(r.state)

    	clock.advance()


    func setup_match(mode_config: Resource) -> void:
    	ai_scheduler = AIScheduler.new()
    	add_child(ai_scheduler)

    	var spawn_pos: Vector2 = arena.limits.get_center() if arena else Vector2(540, 960)
    	player_runner = Runner.new(0, spawn_pos, Vector2.UP, _runner_balance)
    	runners.append(player_runner)
    	runner_spawned.emit(player_runner)

    	var bot_count: int = mode_config.get_meta("bot_count", 0)
    	for i in range(bot_count):
    		var r := Runner.new(i + 1, Vector2(100 + i*50, 100), Vector2.UP, _runner_balance)
    		runners.append(r)

    		# Load archetype based on config
    		var profile := BotProfile.new() # Default for now
    		var brain := BotBrain.new(profile)
    		ai_scheduler.register_bot(r, brain)

    		runner_spawned.emit(r)

    	# A match is created from the menu, so advance the gameplay FSM through its
    	# loading/countdown states before the fixed-step simulation starts.
    	if game_state and game_state.fsm:
    		if game_state.current_state() == GameState.Id.BOOT:
    			game_state.request_transition(GameState.Id.MENU)
    		if game_state.current_state() == GameState.Id.MENU:
    			game_state.request_transition(GameState.Id.LOADING)
    		if game_state.current_state() == GameState.Id.LOADING:
    			game_state.request_transition(GameState.Id.COUNTDOWN)


    func update_time(delta: float) -> void:
    	if game_state.current_state() == GameState.Id.PLAYING:
    		time_elapsed += delta
    		var remaining: float = time_limit_sec - time_elapsed

    		if remaining <= 30.0 and not is_final_push:
    			is_final_push = true
    			final_push_started.emit()


    func check_end_conditions(grid: TerritoryGrid, score_service: ScoreService) -> void:
    	if game_state.current_state() != GameState.Id.PLAYING:
    		return

    	var active_count: int = 0
    	var last_alive: int = -1
    	var placements: Array = []

    	for r in runners:
    		var claim: float = grid.claim_percent(r.state.id)
    		var s: Variant = score_service.runner_scores.get(r.state.id)
    		var total_score: int = s.total_score if s else 0

    		placements.append({"id": r.state.id, "claim": claim, "score": total_score})

    		if r.state.fsm_state != RunnerState.State.ELIMINATED:
    			active_count += 1
    			last_alive = r.state.id

    		if claim >= 0.8: # Domination
    			_end_match(r.state.id, placements, "DOMINATION")
    			return

    	if time_elapsed >= time_limit_sec:
    		placements.sort_custom(func(a, b):
    			if abs(a.claim - b.claim) > 0.001: return a.claim > b.claim
    			return a.score > b.score
    		)
    		_end_match(placements[0].id, placements, "TIME")
    		return

    	if active_count <= 1 and runners.size() > 1:
    		_end_match(last_alive, placements, "LAST_MAN_STANDING")


    func _end_match(winner: int, placements: Array, cause: String) -> void:
    	game_state.request_transition(GameState.Id.PAUSED) # Or RESULTS state
    	var res := MatchResult.new(winner, placements, time_elapsed, cause)
    	match_ended.emit(res)


    func _physics_process(delta: float) -> void:
    	if not game_state or not game_state.fsm:
    		return

    	game_state.fsm.tick(delta)
    	if game_state.current_state() == GameState.Id.PLAYING:
    		step(delta)
    		update_time(delta)
    ```

    Atualize `apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd` — as contagens
    mudam porque `setup_match()` agora sempre cria +1 Runner (o jogador) além dos bots:

    ```gdscript
    extends GutTest

    ## Prova a inversão de dependência da Regra 7 (CLAUDE.md §3) e, desde o Plano 02-05, que
    ## setup_match() cria o Runner do jogador (id 0, sem IA) ANTES dos bots — por isso as
    ## contagens de runner_spawned/runners.size() são bot_count + 1, não bot_count.

    func test_setup_match_emits_runner_spawned_for_player_and_each_bot() -> void:
    	var director := MatchDirector.new()
    	watch_signals(director)

    	var config := Resource.new()
    	config.set_meta("bot_count", 2)
    	director.setup_match(config)

    	assert_eq(get_signal_emit_count(director, "runner_spawned"), 3, "1 jogador + 2 bots")
    	assert_eq(director.runners.size(), 3)
    	assert_true(director.runners[0] is Runner)
    	assert_eq(director.runners[0], director.player_runner, "o primeiro runner criado deveria ser o jogador")

    	director.queue_free()


    func test_setup_match_with_zero_bots_still_emits_for_the_player() -> void:
    	var director := MatchDirector.new()
    	watch_signals(director)

    	var config := Resource.new()
    	config.set_meta("bot_count", 0)
    	director.setup_match(config)

    	assert_eq(get_signal_emit_count(director, "runner_spawned"), 1, "só o jogador, sem bots")
    	assert_not_null(director.player_runner)

    	director.queue_free()
    ```

    Crie `apps/mobile/tests/gameplay/test_headless_movement.gd`:

    ```gdscript
    extends GutTest

    ## Alcançabilidade e determinismo do núcleo de simulação (MOVE-002/003/005, ADR-0014,
    ## ROADMAP Fase 2 critérios de sucesso #1 e #5). Sobe um MatchDirector exatamente como
    ## root.gd faz (configure + setup_match), sem nenhum nó visual (nem RunnerView, nem
    ## GameCamera), e prova: (a) o Runner do jogador se move em resposta a
    ## InputRouter.poll_direction(), nunca a um InputEvent; (b) 600 ticks com a mesma
    ## configuração produzem exatamente o mesmo estado final em 10 execuções.

    func _new_configured_director(bot_count: int) -> MatchDirector:
    	var director: MatchDirector = add_child_autofree(MatchDirector.new())
    	var arena_def := load("res://resources/arenas/open_field.tres") as ArenaDefinition
    	var router := InputRouter.new()
    	director.configure(ConfigService.new(), arena_def, router)
    	var config := Resource.new()
    	config.set_meta("bot_count", bot_count)
    	director.setup_match(config)
    	return director

    func test_player_runner_moves_via_input_router_not_input_event() -> void:
    	var director := _new_configured_director(0)
    	var start_pos := director.player_runner.state.position

    	director.input_router.buffer.push_command(Vector2.RIGHT)
    	for i in range(10):
    		director.step(1.0 / 60.0)

    	assert_gt(director.player_runner.state.position.x, start_pos.x, "o jogador deveria ter se movido para a direita, vindo do InputRouter, sem nenhum InputEvent disparado")

    func test_600_ticks_are_deterministic_across_ten_runs() -> void:
    	var final_positions: Array[Vector2] = []

    	for run in range(10):
    		var director := _new_configured_director(2)
    		for tick in range(600):
    			director.step(1.0 / 60.0)

    		var snapshot := Vector2.ZERO
    		for r in director.runners:
    			snapshot += r.state.position
    		final_positions.append(snapshot)

    	for i in range(1, final_positions.size()):
    		assert_eq(final_positions[i], final_positions[0], "execução %d divergiu da execução 0 após 600 ticks com a mesma configuração" % i)

    func test_headless_simulation_creates_no_visual_node() -> void:
    	var director := _new_configured_director(1)
    	for tick in range(60):
    		director.step(1.0 / 60.0)
    	for child in director.get_children():
    		assert_false(child is Node2D, "a simulação não deveria instanciar nenhum nó visual (Node2D)")
    ```
  </action>
  <acceptance_criteria>
    - `grep -q "func configure(config: ConfigService" apps/mobile/src/gameplay/match_director.gd`
    - `grep -q "player_runner" apps/mobile/src/gameplay/match_director.gd`
    - `grep -q "input_router.poll_direction(delta)" apps/mobile/src/gameplay/match_director.gd`
    - `! grep -q "Camera2D.new()" apps/mobile/src/gameplay/match_director.gd`
    - `grep -q "assert_eq(get_signal_emit_count(director, \"runner_spawned\"), 3" apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd`
    - `test -f apps/mobile/tests/gameplay/test_headless_movement.gd`
    - `./tools/ci/test-client.sh` sai com código 0
    - `./tools/ci/validate-repo.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>grep -q "func configure(config: ConfigService" apps/mobile/src/gameplay/match_director.gd && grep -q "input_router.poll_direction(delta)" apps/mobile/src/gameplay/match_director.gd && ! grep -q "Camera2D.new()" apps/mobile/src/gameplay/match_director.gd && test -f apps/mobile/tests/gameplay/test_headless_movement.gd && ./tools/ci/test-client.sh && ./tools/ci/validate-repo.sh</automated>
  </verify>
  <done>MatchDirector cria um Runner de jogador real, movido por InputRouter através de step(); nenhum Camera2D cru em gameplay/; os testes de contagem atualizados e os 3 testes novos de headless/determinismo/alcançabilidade passam; test-client.sh e validate-repo.sh continuam verdes.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: root.gd — composition root completo (config, input, câmera, CanvasLayer)</name>
  <files>apps/mobile/src/root.gd</files>
  <read_first>
    - apps/mobile/src/root.gd (arquivo inteiro — veja o bloco `<interfaces>` acima para o estado atual completo)
    - apps/mobile/src/core/bootstrap.gd (Bootstrap.registry, autoload global — Plano 02-01)
    - apps/mobile/src/gameplay/match_director.gd (após a Task 1 deste plano: configure(), player_runner, arena)
    - apps/mobile/src/presentation/camera/game_camera.gd (após o Plano 02-04: setup(balance, arena), target_visual)
    - apps/mobile/src/presentation/runner_view_spawner.gd (após o Plano 02-04: RunnerView.runner)
    - apps/mobile/src/ui/navigation/screen_stack.gd (push/replace_root/pop — não muda)
    - docs/architecture/overview.md §1 e §4 (camadas e injeção de dependência: root.gd é o único ponto que conhece gameplay/ E presentation/ ao mesmo tempo)
  </read_first>
  <behavior>
    - A UI (`ScreenStack` e tudo que ela empilha) vive dentro de um `CanvasLayer` — imune à transformação de `GameCamera`
    - `ConfigService` é resolvido de `Bootstrap.registry.resolve("config")` uma vez em `_ready()`, não recriado a cada partida
    - `_start_match()` cria, nesta ordem: `InputRouter` (adicionado à árvore), `MatchDirector` (configurado com config+arena+router ANTES de `setup_match()`), `RunnerViewSpawner` (observando ANTES de `setup_match()`, como já era), `GameCamera` (com `setup()` e `make_current()`), depois roda `setup_match()`, e só então encontra a `RunnerView` do `player_runner` entre as views recém-criadas para virar o alvo da câmera
    - `_return_to_menu()` libera também `InputRouter` e `GameCamera`, além do que já liberava
  </behavior>
  <action>
    Reescreva `apps/mobile/src/root.gd` por inteiro (o arquivo atual está no bloco
    `<interfaces>` acima):

    ```gdscript
    extends Control

    var screen_stack: ScreenStack
    var _match_director: MatchDirector
    var _runner_view_spawner: RunnerViewSpawner
    var _input_router: InputRouter
    var _game_camera: GameCamera
    var _config: ConfigService

    func _ready() -> void:
    	var ui_layer := CanvasLayer.new()
    	add_child(ui_layer)

    	screen_stack = ScreenStack.new()
    	ui_layer.add_child(screen_stack)
    	screen_stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    	_config = Bootstrap.registry.resolve("config") as ConfigService

    	var splash := SplashScreen.new()
    	splash.finished.connect(_show_main_menu)
    	screen_stack.push(splash)

    func _show_main_menu() -> void:
    	var menu := MainMenuScreen.new()
    	menu.play_requested.connect(_start_match)
    	screen_stack.replace_root(menu)

    func _start_match() -> void:
    	if is_instance_valid(_match_director):
    		return

    	var match_screen := MatchScreen.new()
    	match_screen.exit_requested.connect(_return_to_menu)
    	screen_stack.push(match_screen)

    	var arena_definition := load("res://resources/arenas/open_field.tres") as ArenaDefinition

    	_input_router = InputRouter.new()
    	add_child(_input_router)

    	_match_director = MatchDirector.new()
    	add_child(_match_director)
    	_match_director.configure(_config, arena_definition, _input_router)

    	_runner_view_spawner = RunnerViewSpawner.new()
    	add_child(_runner_view_spawner)
    	_runner_view_spawner.watch(_match_director)

    	_game_camera = GameCamera.new()
    	add_child(_game_camera)
    	if _config:
    		_game_camera.setup(_config.camera(), _match_director.arena)
    	_game_camera.make_current()

    	var config := Resource.new()
    	config.set_meta("bot_count", 3)
    	_match_director.setup_match(config)
    	match_screen.set_bot_count(3)

    	for view in _runner_view_spawner.get_children():
    		if view.runner == _match_director.player_runner:
    			_game_camera.target_visual = view
    			break

    func _return_to_menu() -> void:
    	if is_instance_valid(_match_director):
    		_match_director.queue_free()
    		_match_director = null

    	if is_instance_valid(_runner_view_spawner):
    		_runner_view_spawner.queue_free()
    		_runner_view_spawner = null

    	if is_instance_valid(_input_router):
    		_input_router.queue_free()
    		_input_router = null

    	if is_instance_valid(_game_camera):
    		_game_camera.queue_free()
    		_game_camera = null

    	if screen_stack and screen_stack.can_pop():
    		screen_stack.pop()
    ```

    Note que `_game_camera`/`_input_router`/`_match_director`/`_runner_view_spawner` são todos
    filhos diretos de `root` (fora do `CanvasLayer` da UI) — é isso que garante que só a UI
    fica imune à câmera, e que `RunnerView`s criadas por `_runner_view_spawner` (também filho
    de `root`, fora do `CanvasLayer`) recebem a transformação de câmera normalmente.
  </action>
  <acceptance_criteria>
    - `grep -q "CanvasLayer.new()" apps/mobile/src/root.gd`
    - `grep -q "Bootstrap.registry.resolve(\"config\")" apps/mobile/src/root.gd`
    - `grep -q "_match_director.configure(_config, arena_definition, _input_router)" apps/mobile/src/root.gd`
    - `grep -q "_game_camera.setup(_config.camera(), _match_director.arena)" apps/mobile/src/root.gd`
    - `grep -q "_game_camera.make_current()" apps/mobile/src/root.gd`
    - `./tools/ci/test-client.sh` sai com código 0
    - `./tools/ci/validate-repo.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>grep -q "CanvasLayer.new()" apps/mobile/src/root.gd && grep -q "Bootstrap.registry.resolve(\"config\")" apps/mobile/src/root.gd && grep -q "_match_director.configure(_config, arena_definition, _input_router)" apps/mobile/src/root.gd && ./tools/ci/test-client.sh && ./tools/ci/validate-repo.sh</automated>
  </verify>
  <done>root.gd envolve a UI num CanvasLayer, resolve ConfigService do Bootstrap, cria e liga InputRouter/GameCamera/MatchDirector/RunnerViewSpawner na ordem certa, e libera os quatro ao voltar ao menu; test-client.sh e validate-repo.sh continuam verdes.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: FSM do jogo através do MatchDirector real + Paused congela tudo</name>
  <files>apps/mobile/tests/integration/test_match_lifecycle.gd, apps/mobile/tests/integration/test_pause_freeze.gd, apps/mobile/tests/integration/test_runner_presentation_wiring.gd</files>
  <read_first>
    - apps/mobile/src/gameplay/match_director.gd (após a Task 1 deste plano — game_state, clock, player_runner)
    - apps/mobile/src/gameplay/game_state.gd (após o Plano 02-02 — as 11 transições, PausedState congelando via SceneTree.paused)
    - apps/mobile/tests/integration/test_runner_presentation_wiring.gd (o teste que este plano precisa ATUALIZAR — mesma mudança de contagem da Task 1)
    - .gsd/phases/02-core-movement/TESTS.md, seção Integration (test_match_lifecycle.gd, test_pause_freeze.gd)
  </read_first>
  <behavior>
    - `setup_match()` avança a FSM de `Boot` até `Countdown` (comportamento já existente, agora provado através do `MatchDirector` real, não só de `GameState` isolado)
    - O ciclo completo `Countdown -> Playing -> Paused -> Playing -> Results -> Loading` funciona através de `MatchDirector.game_state`
    - Rodar `_physics_process` em `Paused` não avança `player_runner.state.position`, `clock.current_tick` nem `time_elapsed` — nem um pouco, mesmo chamando o método várias vezes
    - Retomar de `Paused` para `Playing` volta a avançar o tick
    - `RunnerViewSpawner` cria uma `RunnerView` por Runner, incluindo o jogador (bot_count + 1)
  </behavior>
  <action>
    Crie `apps/mobile/tests/integration/test_match_lifecycle.gd`:

    ```gdscript
    extends GutTest

    ## FSM do jogo através do MatchDirector real (MOVE-001/002, ACCEPTANCE A02-08, ROADMAP
    ## Fase 2 critério de sucesso #6). A cobertura da StateMachine isolada já está em
    ## test_game_state.gd (Plano 02-02) — este teste prova o mesmo ciclo através do
    ## MatchDirector de verdade, do jeito que root.gd o usa.

    func _new_director_in_countdown(bot_count: int = 0) -> MatchDirector:
    	var director: MatchDirector = add_child_autofree(MatchDirector.new())
    	var config := Resource.new()
    	config.set_meta("bot_count", bot_count)
    	director.setup_match(config)
    	return director

    func test_setup_match_advances_from_boot_to_countdown() -> void:
    	var director := _new_director_in_countdown()
    	assert_eq(director.game_state.current_state(), GameState.Id.COUNTDOWN)

    func test_full_cycle_reaches_results_and_can_restart() -> void:
    	var director := _new_director_in_countdown()

    	director.game_state.request_transition(GameState.Id.PLAYING)
    	assert_eq(director.game_state.current_state(), GameState.Id.PLAYING)

    	director.game_state.request_transition(GameState.Id.PAUSED)
    	assert_eq(director.game_state.current_state(), GameState.Id.PAUSED)

    	director.game_state.request_transition(GameState.Id.PLAYING)
    	assert_eq(director.game_state.current_state(), GameState.Id.PLAYING)

    	director.game_state.request_transition(GameState.Id.RESULTS)
    	assert_eq(director.game_state.current_state(), GameState.Id.RESULTS)

    	director.game_state.request_transition(GameState.Id.LOADING)
    	assert_eq(director.game_state.current_state(), GameState.Id.LOADING, "Results -> Loading (jogar de novo)")
    ```

    Crie `apps/mobile/tests/integration/test_pause_freeze.gd`:

    ```gdscript
    extends GutTest

    ## Paused congela tudo (MOVE-001, ACCEPTANCE A02-09, ROADMAP Fase 2 critério de sucesso
    ## #6). Chama _physics_process diretamente em vez de depender de SceneTree.paused (que é a
    ## segunda camada de proteção usada no jogo real via PauseScreen — ver Plano 02-06):
    ## enquanto GameState.Id.PLAYING não voltar, nada deveria avançar.

    func _new_playing_director() -> MatchDirector:
    	var director: MatchDirector = add_child_autofree(MatchDirector.new())
    	var arena_def := load("res://resources/arenas/open_field.tres") as ArenaDefinition
    	director.configure(ConfigService.new(), arena_def, InputRouter.new())
    	var config := Resource.new()
    	config.set_meta("bot_count", 1)
    	director.setup_match(config)
    	director.game_state.request_transition(GameState.Id.PLAYING)
    	return director

    func test_paused_freezes_position_tick_and_elapsed_time() -> void:
    	var director := _new_playing_director()

    	for i in range(30):
    		director._physics_process(1.0 / 60.0)

    	var frozen_position := director.player_runner.state.position
    	var frozen_tick := director.clock.current_tick
    	var frozen_time := director.time_elapsed

    	director.game_state.request_transition(GameState.Id.PAUSED)

    	for i in range(30):
    		director._physics_process(1.0 / 60.0)

    	assert_eq(director.player_runner.state.position, frozen_position, "posição não deveria avançar durante o Paused")
    	assert_eq(director.clock.current_tick, frozen_tick, "o tick da simulação não deveria avançar durante o Paused")
    	assert_eq(director.time_elapsed, frozen_time, "o tempo decorrido não deveria avançar durante o Paused")

    func test_resuming_from_paused_continues_advancing() -> void:
    	var director := _new_playing_director()

    	for i in range(10):
    		director._physics_process(1.0 / 60.0)

    	director.game_state.request_transition(GameState.Id.PAUSED)
    	for i in range(10):
    		director._physics_process(1.0 / 60.0)
    	var paused_tick := director.clock.current_tick

    	director.game_state.request_transition(GameState.Id.PLAYING)
    	for i in range(10):
    		director._physics_process(1.0 / 60.0)

    	assert_gt(director.clock.current_tick, paused_tick, "retomar o jogo deveria voltar a avançar o tick")
    ```

    Atualize `apps/mobile/tests/integration/test_runner_presentation_wiring.gd` (mesma razão da
    Task 1 — agora existe sempre +1 Runner, o jogador):

    ```gdscript
    extends GutTest

    ## Prova a ponta de apresentação da inversão de dependência: RunnerViewSpawner cria uma
    ## RunnerView por Runner emitido por MatchDirector, incluindo o jogador — desde o Plano
    ## 02-05, setup_match() sempre cria +1 Runner (o jogador) além dos bots.

    func test_spawner_creates_a_runner_view_per_runner_including_the_player() -> void:
    	var director := MatchDirector.new()
    	var spawner := RunnerViewSpawner.new()
    	spawner.watch(director)

    	var config := Resource.new()
    	config.set_meta("bot_count", 3)
    	director.setup_match(config)

    	assert_eq(spawner.get_child_count(), 4, "1 jogador + 3 bots")
    	for child in spawner.get_children():
    		assert_true(child is RunnerView, "cada filho deveria ser uma RunnerView")

    	spawner.queue_free()
    	director.queue_free()
    ```
  </action>
  <acceptance_criteria>
    - `test -f apps/mobile/tests/integration/test_match_lifecycle.gd`
    - `test -f apps/mobile/tests/integration/test_pause_freeze.gd`
    - `grep -q "assert_eq(spawner.get_child_count(), 4" apps/mobile/tests/integration/test_runner_presentation_wiring.gd`
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>test -f apps/mobile/tests/integration/test_match_lifecycle.gd && test -f apps/mobile/tests/integration/test_pause_freeze.gd && grep -q "assert_eq(spawner.get_child_count(), 4" apps/mobile/tests/integration/test_runner_presentation_wiring.gd && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>test_match_lifecycle.gd prova o ciclo completo da FSM através do MatchDirector real; test_pause_freeze.gd prova que Paused congela posição/tick/tempo e que retomar volta a avançar; test_runner_presentation_wiring.gd atualizado para 4 views (1+3); test-client.sh continua verde.</done>
</task>

</tasks>

<verification>
- `./tools/ci/test-client.sh` sai com código 0
- `./tools/ci/validate-repo.sh` sai com código 0 (nenhuma regressão nas 10 regras, incluindo a Regra 7 de camadas)
- `./tools/ci/lint.sh` sai com código 0
- `grep -c "Camera2D" apps/mobile/src/gameplay/match_director.gd` retorna 0
- Os 5 arquivos de teste tocados por este plano (2 atualizados + 3 novos) passam dentro da suíte GUT
</verification>

<success_criteria>
Ao tocar PLAY no jogo real, existe agora um Runner de jogador simulado a 60 Hz fixo, movido
exclusivamente por `InputRouter`, contido pela `Arena`, com velocidade/giro de `RunnerBalance` —
critérios de sucesso #1, #2 e #3 do ROADMAP da Fase 2. `root.gd` é o composition root completo:
resolve config do Bootstrap, cria `InputRouter`/`GameCamera`/`MatchDirector`/`RunnerViewSpawner`
na ordem certa, e isola a UI da câmera com um `CanvasLayer`. `gameplay/` não cria mais nenhum
`Camera2D` cru. O Plano 02-06 (MatchScreen) pode agora parar de simular e só mostrar o que a
simulação real entrega.
</success_criteria>

<output>
Após completar, crie `.planning/phases/02-core-movement/02-05-SUMMARY.md` seguindo o template
de summary.md, registrando a criação do Runner de jogador, a composição em root.gd, e a
descoberta/correção do risco de CanvasLayer.
</output>
</content>
