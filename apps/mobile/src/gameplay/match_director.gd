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
	# 1. input
	# 2. movement
	# 3. mark arcs
	# 4. detect collisions (breaks, backwash)
	# 5. resolve seals (by runner_id)
	# 6. process eliminations (squeeze, break)
	# 7. respawn
	# 8. events
	
	clock.advance()

var ai_scheduler: AIScheduler
var runners: Array[Runner] = []

func setup_match(mode_config: Resource) -> void:
	ai_scheduler = AIScheduler.new()
	add_child(ai_scheduler)
	
	var cam = Camera2D.new()
	cam.position = Vector2(540, 960) # Center of screen
	add_child(cam)
	
	var bot_count = mode_config.get_meta("bot_count", 0)
	for i in range(bot_count):
		var r = Runner.new(i + 1, Vector2(100 + i*50, 100), Vector2.UP)
		runners.append(r)
		
		# Load archetype based on config
		var profile = BotProfile.new() # Default for now
		var brain = BotBrain.new(profile)
		ai_scheduler.register_bot(r, brain)
		
		# Visualization
		if ClassDB.class_exists("RunnerView"):
			var view = load("res://src/presentation/runner_view.gd").new()
			add_child(view)
			view.position = r.state.position
			
			# If catalog/loadout are available via Autoload, we would apply cosmetics here


var time_limit_sec: float = 180.0
var time_elapsed: float = 0.0
var is_final_push: bool = false
signal final_push_started

func update_time(delta: float) -> void:
	if game_state.current_state() == GameState.Id.PLAYING:
		time_elapsed += delta
		var remaining = time_limit_sec - time_elapsed
		
		if remaining <= 30.0 and not is_final_push:
			is_final_push = true
			final_push_started.emit()

signal match_ended(result: MatchResult)

func check_end_conditions(grid: TerritoryGrid, score_service: ScoreService) -> void:
	if game_state.current_state() != GameState.Id.PLAYING:
		return
		
	var active_count = 0
	var last_alive = -1
	var placements = []
	
	for r in runners:
		var claim = grid.claim_percent(r.state.id)
		var s = score_service.runner_scores.get(r.state.id)
		var total_score = s.total_score if s else 0
		
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
	var res = MatchResult.new(winner, placements, time_elapsed, cause)
	match_ended.emit(res)

func _physics_process(delta: float) -> void:
	if game_state and game_state.current_state() == GameState.Id.PLAYING:
		step(delta)
