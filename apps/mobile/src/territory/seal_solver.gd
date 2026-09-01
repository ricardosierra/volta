class_name SealSolver
extends RefCounted

## Pure function to solve the seal logic via exterior flood-fill.
static func solve(runner_id: int, grid: TerritoryGrid, arc_tracker: ArcTracker) -> SealResult:
	var result := SealResult.new()
	result.runner_id = runner_id

	if arc_tracker.length() == 0:
		return result

	var bbox := _compute_bounding_box(arc_tracker, grid)
	result.bounding_box = bbox

	var visited := _flood_fill_exterior(bbox, grid, runner_id)
	_collect_captured_cells(bbox, grid, runner_id, visited, result)

	for idx in arc_tracker._cells:
		result.captured_cells.append(idx)

	return result


## Bounding box do Arc, expandido em 1 célula para dar espaço ao flood fill exterior.
static func _compute_bounding_box(arc_tracker: ArcTracker, grid: TerritoryGrid) -> Rect2i:
	var min_x: int = grid.width
	var max_x: int = 0
	var min_y: int = grid.height
	var max_y: int = 0

	for idx in arc_tracker._cells:
		var x: int = idx % grid.width
		var y: int = idx / grid.width
		if x < min_x: min_x = x
		if x > max_x: max_x = x
		if y < min_y: min_y = y
		if y > max_y: max_y = y

	min_x = maxi(0, min_x - 1)
	max_x = mini(grid.width - 1, max_x + 1)
	min_y = maxi(0, min_y - 1)
	max_y = mini(grid.height - 1, max_y + 1)

	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


## Flood fill a partir da borda da bounding box, marcando como "visitado" (exterior) tudo
## que não é claim nem arc do runner_id. O que sobra não-visitado é a região fechada.
static func _flood_fill_exterior(bbox: Rect2i, grid: TerritoryGrid, runner_id: int) -> PackedByteArray:
	var min_x: int = bbox.position.x
	var min_y: int = bbox.position.y
	var max_x: int = bbox.position.x + bbox.size.x - 1
	var max_y: int = bbox.position.y + bbox.size.y - 1
	var bbox_w: int = bbox.size.x

	var visited := PackedByteArray()
	visited.resize(bbox.size.x * bbox.size.y)
	visited.fill(0)

	var queue := PackedInt32Array()

	for x in range(min_x, max_x + 1):
		_enqueue_if_exterior(x, min_y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)
		_enqueue_if_exterior(x, max_y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)

	for y in range(min_y + 1, max_y):
		_enqueue_if_exterior(min_x, y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)
		_enqueue_if_exterior(max_x, y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)

	var dx: Array[int] = [1, -1, 0, 0]
	var dy: Array[int] = [0, 0, 1, -1]

	var q_idx: int = 0
	while q_idx < queue.size():
		var pt_idx: int = queue[q_idx]
		q_idx += 1

		var lx: int = pt_idx % bbox_w
		var ly: int = pt_idx / bbox_w
		var gx: int = min_x + lx
		var gy: int = min_y + ly

		for i in range(4):
			var nx: int = gx + dx[i]
			var ny: int = gy + dy[i]

			if nx >= min_x and nx <= max_x and ny >= min_y and ny <= max_y:
				_enqueue_if_exterior(nx, ny, min_x, min_y, bbox_w, grid, runner_id, queue, visited)

	return visited


## As células não visitadas pelo flood fill exterior (e que não são barreira) foram
## fechadas pelo Seal: entram em captured_cells, e quem era dono/arco alheio entra em
## stolen_from_owners/swallowed_arcs.
static func _collect_captured_cells(bbox: Rect2i, grid: TerritoryGrid, runner_id: int, visited: PackedByteArray, result: SealResult) -> void:
	var min_x: int = bbox.position.x
	var min_y: int = bbox.position.y
	var max_x: int = bbox.position.x + bbox.size.x - 1
	var max_y: int = bbox.position.y + bbox.size.y - 1
	var bbox_w: int = bbox.size.x

	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var lx: int = x - min_x
			var ly: int = y - min_y
			var local_idx: int = ly * bbox_w + lx

			if visited[local_idx] == 0:
				var global_idx: int = grid.cell_index(x, y)
				var is_our_claim: bool = grid._owner[global_idx] == runner_id
				var is_our_arc: bool = grid._arc[global_idx] == runner_id
				var is_blocked: bool = grid.is_blocked(x, y)

				if not is_our_claim and not is_our_arc and not is_blocked:
					result.captured_cells.append(global_idx)

					var owner: int = grid._owner[global_idx]
					if owner != 254 and owner != 255:
						if not result.stolen_from_owners.has(owner):
							result.stolen_from_owners[owner] = 0
						result.stolen_from_owners[owner] += 1

					var arc_owner: int = grid._arc[global_idx]
					if arc_owner != 255 and arc_owner != runner_id:
						if not result.swallowed_arcs.has(arc_owner):
							result.swallowed_arcs.append(arc_owner)


static func _enqueue_if_exterior(gx: int, gy: int, min_x: int, min_y: int, bbox_w: int, grid: TerritoryGrid, runner_id: int, queue: PackedInt32Array, visited: PackedByteArray) -> void:
	var lx: int = gx - min_x
	var ly: int = gy - min_y
	var local_idx: int = ly * bbox_w + lx

	if visited[local_idx] == 1:
		return

	var global_idx: int = grid.cell_index(gx, gy)
	var is_our_claim: bool = grid._owner[global_idx] == runner_id
	var is_our_arc: bool = grid._arc[global_idx] == runner_id

	if not is_our_claim and not is_our_arc:
		visited[local_idx] = 1
		queue.append(local_idx)
