class_name BotSteering
extends RefCounted

func get_desired_velocity(current_pos: Vector2, target_pos: Vector2, speed: float, arena: ArenaDefinition) -> Vector2:
	var desired := (target_pos - current_pos).normalized() * speed
	
	if not arena:
		return desired
		
	# Raycast logically to detect if blocked
	var test_pos := current_pos + desired.normalized() * 50.0
	if arena.is_blocked(test_pos) or arena.is_hazard(test_pos):
		# Steer away (simple slide)
		var avoid := test_pos.direction_to(current_pos)
		desired = (desired + avoid * speed).normalized() * speed
		
	return desired
