class_name Runner
extends RefCounted

var state: RunnerState
var stats: StatBlock

func _init(runner_id: int, start_pos: Vector2, start_dir: Vector2, balance: RunnerBalance = null) -> void:
	state = RunnerState.new()
	state.id = runner_id
	state.position = start_pos
	state.direction = start_dir
	state.desired_direction = start_dir
	stats = StatBlock.new(balance)

func set_desired_direction(dir: Vector2) -> void:
	if dir.length_squared() > 0.01:
		state.desired_direction = dir.normalized()

func tick(delta: float) -> void:
	Movement.step(state, stats, delta)
