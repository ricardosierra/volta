class_name Movement
extends RefCounted

static func step(state: RunnerState, stats: StatBlock, delta: float) -> void:
	if state.fsm_state == RunnerState.State.ELIMINATED:
		state.velocity = Vector2.ZERO
		return
		
	var turn_rate_rad = deg_to_rad(stats.get_turn_rate())
	var current_angle = state.direction.angle()
	var desired_angle = state.desired_direction.angle()
	
	var new_angle = rotate_toward(current_angle, desired_angle, turn_rate_rad * delta)
	state.direction = Vector2.RIGHT.rotated(new_angle)
	state.velocity = state.direction * stats.get_speed()
	state.position += state.velocity * delta
