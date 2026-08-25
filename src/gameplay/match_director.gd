class_name MatchDirector
extends Node

var clock: SimulationClock
var resolver: CollisionResolver
var elimination: EliminationService

func _ready() -> void:
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
	
	var bot_count = mode_config.get_meta("bot_count", 0)
	for i in range(bot_count):
		var r = Runner.new(i + 1, Vector2(100 + i*50, 100), Vector2.UP)
		runners.append(r)
		
		# Load archetype based on config
		var profile = BotProfile.new() # Default for now
		var brain = BotBrain.new(profile)
		ai_scheduler.register_bot(r, brain)

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
