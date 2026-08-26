class_name SealApplier
extends RefCounted

signal seal_completed(runner_id: int, cells: PackedInt32Array, stolen: Dictionary, bbox: Rect2i)
signal arc_swallowed(victim: int, by_runner: int)
signal squeezed(victim: int, by_runner: int)

func apply(result: SealResult, grid: TerritoryGrid, tracker: ArcTracker) -> void:
	for cell_idx in result.captured_cells:
		var x = cell_idx % grid.width
		var y = cell_idx / grid.width
		grid.set_owner(x, y, result.runner_id)
		
	tracker.clear()
	
	seal_completed.emit(result.runner_id, result.captured_cells, result.stolen_from_owners, result.bounding_box)
	
	for victim in result.swallowed_arcs:
		arc_swallowed.emit(victim, result.runner_id)
		
	for victim in result.stolen_from_owners:
		if grid._claim_count[victim] == 0:
			squeezed.emit(victim, result.runner_id)
