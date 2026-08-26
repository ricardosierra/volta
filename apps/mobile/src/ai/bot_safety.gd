class_name BotSafety
extends RefCounted

var stuck_timer: float = 0.0
var last_cell: Vector2i = Vector2i(-1, -1)
var is_stuck: bool = false
var emergency_dir: Vector2 = Vector2.ZERO

func check(runner: Runner, delta: float, space: GridSpace) -> Vector2:
	var current_cell = space.world_to_cell(runner.state.position)
	if current_cell == last_cell:
		stuck_timer += delta
	else:
		stuck_timer = 0.0
		last_cell = current_cell
		is_stuck = false
		
	if stuck_timer > 1.5:
		is_stuck = true
		if stuck_timer > 3.0: # Re-roll emergency direction
			emergency_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			stuck_timer = 1.5
			
	if is_stuck:
		return emergency_dir
		
	return Vector2.ZERO
