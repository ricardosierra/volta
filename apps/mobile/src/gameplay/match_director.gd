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


## Posição de nascimento do runner `index`, vinda dos spawn_points da ArenaDefinition —
## nunca de literal no código (CLAUDE.md regra 4). Antes disto os bots nasciam todos em
## Vector2(100 + i*50, 100): empilhados no canto da arena, a 1300 unidades do jogador, que
## nasce no centro. Se faltarem pontos para todos, distribui os que sobram num círculo em
## volta do centro, para nunca empilhar dois runners no mesmo lugar.
func _spawn_position(index: int, total: int) -> Vector2:
	if arena and arena.definition:
		var points: Array[Vector2] = arena.definition.spawn_points
		if index < points.size():
			return points[index]

	if not arena:
		return Vector2.ZERO

	var spawn_count := arena.definition.spawn_points.size() if arena.definition else 0
	var center := arena.limits.get_center()
	var radius := minf(arena.limits.size.x, arena.limits.size.y) * 0.25
	var placed := maxi(spawn_count, 1)
	var extra := index - placed
	var remaining := maxi(1, total - placed)
	var angle := TAU * float(extra) / float(remaining)
	return center + Vector2.RIGHT.rotated(angle) * radius


func setup_match(mode_config: Resource) -> void:
	ai_scheduler = AIScheduler.new()
	add_child(ai_scheduler)

	var bot_count: int = mode_config.get_meta("bot_count", 0)
	var total_runners := bot_count + 1

	var spawn_pos: Vector2 = _spawn_position(0, total_runners) if arena else Vector2(540, 960)
	player_runner = Runner.new(0, spawn_pos, Vector2.UP, _runner_balance)
	runners.append(player_runner)
	runner_spawned.emit(player_runner)

	for i in range(bot_count):
		var r := Runner.new(i + 1, _spawn_position(i + 1, total_runners), Vector2.UP, _runner_balance)
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
		# Sort placements: claim desc, then score desc
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
