class_name MatchDirector
extends Node

var clock: SimulationClock

func _ready() -> void:
	clock = SimulationClock.new(0)
	
	# Sync max FPS with the panel refresh rate if possible, but keep physics tick at 60.
	Engine.max_fps = DisplayServer.screen_get_refresh_rate()
	if Engine.max_fps == -1:
		Engine.max_fps = 60 # Default fallback

func _physics_process(delta: float) -> void:
	step(delta)

func step(delta: float) -> void:
	# Fixed order of execution:
	# 1. input
	# 2. (IA)
	# 3. movement
	# 4. (territory)
	# 5. (regras)
	# 6. eventos
	
	clock.advance()
