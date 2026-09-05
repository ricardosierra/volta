class_name BackwashState
extends State

var runner: Runner
var penalty_time: float = 2.0
var _timer: float = 0.0

func _init(r: Runner) -> void:
	runner = r

func enter() -> void:
	# Add speed penalty modifier
	runner.stats.add_speed_modifier(-100.0)
	_timer = penalty_time

func update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		# Return to safe or drawing
		runner.stats.remove_speed_modifier(-100.0)
		# Needs FSM reference to transition back, skipped for stub
