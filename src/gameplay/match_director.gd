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
