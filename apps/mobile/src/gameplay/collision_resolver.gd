class_name CollisionResolver
extends RefCounted

signal runner_break_requested(victim_id: int, killer_id: int)
signal backwash_requested(runner_id: int)

func detect_and_resolve(runners: Array, grid: TerritoryGrid) -> void:
	var breaks_to_apply = []
	var backwashes_to_apply = []
	
	for r in runners:
		if r.state.fsm_state != RunnerState.State.SPAWN and r.state.fsm_state != RunnerState.State.ELIMINATED:
			var cx = int(floor(r.state.position.x / grid.cell_size))
			var cy = int(floor(r.state.position.y / grid.cell_size))
			
			if grid.is_valid(cx, cy):
				var cell_arc = grid.arc_owner_of(cx, cy)
				
				# Check arc intersection
				if cell_arc != 255:
					if cell_arc != r.state.id:
						# We hit someone else's arc -> Break the owner of the arc
						# Wait, no, hitting an arc breaks the runner whose arc was hit?
						# Or hitting an arc kills the person who owns the arc?
						# R5.1: "Cortar o Arc: Se um Runner (o Cortador) cruza o rastro (Arc) de outro Runner (a Vítima), a Vítima é Eliminada."
						breaks_to_apply.append({"victim": cell_arc, "killer": r.state.id})
					else:
						# We hit our own arc -> Backwash
						if r.state.fsm_state == RunnerState.State.SPAWN: # DrawingTrail equivalent
							backwashes_to_apply.append(r.state.id)
							
			# Wall collision check
			if cx < 0 or cy < 0 or cx >= grid.width or cy >= grid.height or grid.is_blocked(cx, cy):
				if r.state.fsm_state == RunnerState.State.SPAWN: # DrawingTrail equivalent
					backwashes_to_apply.append(r.state.id)
					
	# Apply
	for b in breaks_to_apply:
		runner_break_requested.emit(b.victim, b.killer)
		
	for bw in backwashes_to_apply:
		backwash_requested.emit(bw)
