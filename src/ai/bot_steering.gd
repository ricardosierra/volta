class_name BotSteering
extends RefCounted

static func steer(runner: Runner, desired_dir: Vector2, grid: TerritoryGrid) -> Vector2:
	# Local avoidance logic
	var cx = int(floor(runner.state.position.x / grid.cell_size))
	var cy = int(floor(runner.state.position.y / grid.cell_size))
	
	# Very basic avoidance
	var safe_dir = desired_dir
	var lookahead_dist = 2
	
	var tx = cx + int(round(desired_dir.x * lookahead_dist))
	var ty = cy + int(round(desired_dir.y * lookahead_dist))
	
	if not grid.is_valid(tx, ty) or grid.is_blocked(tx, ty):
		# Steer away from wall
		safe_dir = desired_dir.rotated(PI/4) # Attempt 45 deg deflection
		
	return safe_dir.normalized()
