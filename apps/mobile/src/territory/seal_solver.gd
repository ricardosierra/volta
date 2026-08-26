class_name SealSolver
extends RefCounted

## Pure function to solve the seal logic via exterior flood-fill.
static func solve(runner_id: int, grid: TerritoryGrid, arc_tracker: ArcTracker) -> SealResult:
	var result = SealResult.new()
	result.runner_id = runner_id
	
	if arc_tracker.length() == 0:
		return result
		
	# 1. Bounding box calculation
	var min_x = grid.width
	var max_x = 0
	var min_y = grid.height
	var max_y = 0
	
	for idx in arc_tracker._cells:
		var x = idx % grid.width
		var y = idx / grid.width
		if x < min_x: min_x = x
		if x > max_x: max_x = x
		if y < min_y: min_y = y
		if y > max_y: max_y = y
		
	# Expand by 1 for exterior flood fill
	min_x = maxi(0, min_x - 1)
	max_x = mini(grid.width - 1, max_x + 1)
	min_y = maxi(0, min_y - 1)
	max_y = mini(grid.height - 1, max_y + 1)
	
	result.bounding_box = Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
	
	# We use a bit vector or just a packed byte array for visited state
	var bbox_w = result.bounding_box.size.x
	var bbox_h = result.bounding_box.size.y
	var visited = PackedByteArray()
	visited.resize(bbox_w * bbox_h)
	visited.fill(0)
	
	var queue = PackedInt32Array()
	
	# Enqueue boundaries of the bbox
	for x in range(min_x, max_x + 1):
		_enqueue_if_exterior(x, min_y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)
		_enqueue_if_exterior(x, max_y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)
		
	for y in range(min_y + 1, max_y):
		_enqueue_if_exterior(min_x, y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)
		_enqueue_if_exterior(max_x, y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)
		
	# Flood fill
	var dx = [1, -1, 0, 0]
	var dy = [0, 0, 1, -1]
	
	var q_idx = 0
	while q_idx < queue.size():
		var pt_idx = queue[q_idx]
		q_idx += 1
		
		var lx = pt_idx % bbox_w
		var ly = pt_idx / bbox_w
		var gx = min_x + lx
		var gy = min_y + ly
		
		for i in range(4):
			var nx = gx + dx[i]
			var ny = gy + dy[i]
			
			if nx >= min_x and nx <= max_x and ny >= min_y and ny <= max_y:
				_enqueue_if_exterior(nx, ny, min_x, min_y, bbox_w, grid, runner_id, queue, visited)
				
	# Captured are the unvisited non-barrier cells
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var lx = x - min_x
			var ly = y - min_y
			var local_idx = ly * bbox_w + lx
			
			if visited[local_idx] == 0:
				# Check if it's a barrier (our claim or arc)
				var global_idx = grid.cell_index(x, y)
				var is_our_claim = grid._owner[global_idx] == runner_id
				var is_our_arc = grid._arc[global_idx] == runner_id
				var is_blocked = grid.is_blocked(x, y)
				
				if not is_our_claim and not is_our_arc and not is_blocked:
					result.captured_cells.append(global_idx)
					
					var owner = grid._owner[global_idx]
					if owner != 254 and owner != 255:
						if not result.stolen_from_owners.has(owner):
							result.stolen_from_owners[owner] = 0
						result.stolen_from_owners[owner] += 1
						
					var arc_owner = grid._arc[global_idx]
					if arc_owner != 255 and arc_owner != runner_id:
						if not result.swallowed_arcs.has(arc_owner):
							result.swallowed_arcs.append(arc_owner)
							
	# Arc cells are also "captured" into claims
	for idx in arc_tracker._cells:
		result.captured_cells.append(idx)
		
	return result

static func _enqueue_if_exterior(gx: int, gy: int, min_x: int, min_y: int, bbox_w: int, grid: TerritoryGrid, runner_id: int, queue: PackedInt32Array, visited: PackedByteArray) -> void:
	var lx = gx - min_x
	var ly = gy - min_y
	var local_idx = ly * bbox_w + lx
	
	if visited[local_idx] == 1:
		return
		
	var global_idx = grid.cell_index(gx, gy)
	var is_our_claim = grid._owner[global_idx] == runner_id
	var is_our_arc = grid._arc[global_idx] == runner_id
	
	if not is_our_claim and not is_our_arc:
		visited[local_idx] = 1
		queue.append(local_idx)
