class_name Perception
extends RefCounted

var enemy_awareness_radius: float = 800.0

func gather(runner: Runner, all_runners: Array, grid: TerritoryGrid) -> Dictionary:
	var visible_enemies = []
	var threat_map = {}
	var opportunity_map = {}
	
	for r in all_runners:
		if r != runner and r.state.fsm_state != RunnerState.State.ELIMINATED:
			var dist = runner.state.position.distance_to(r.state.position)
			if dist <= enemy_awareness_radius:
				visible_enemies.append(r)
				
	# Build threat map (distance to our arc)
	# Build opportunity map (cells to capture nearby)
	# For now, minimal stub of the context object
	
	return {
		"me": runner,
		"visible_enemies": visible_enemies,
		"threats": threat_map,
		"opportunities": opportunity_map,
		"grid": grid
	}
