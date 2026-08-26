class_name ArcTracker
extends RefCounted

signal self_intersect(runner_id: int, intersection_cell: Vector2i)

var runner_id: int
var _cells: PackedInt32Array
var grid: TerritoryGrid
var max_cells: int = 1200

func _init(id: int, target_grid: TerritoryGrid) -> void:
	runner_id = id
	grid = target_grid
	_cells = PackedInt32Array()

func mark(from_cell: Vector2i, to_cell: Vector2i) -> void:
	var path = ArcRasterizer.supercover_line(from_cell, to_cell)
	for cell in path:
		if not grid.is_valid(cell.x, cell.y):
			continue
			
		var idx = grid.cell_index(cell.x, cell.y)
		
		# Check self intersection
		if grid._arc[idx] == runner_id and _cells.size() > 0:
			var is_last = _cells[_cells.size() - 1] == idx
			if not is_last:
				self_intersect.emit(runner_id, cell)
				
		if grid._arc[idx] != runner_id:
			grid._arc[idx] = runner_id
			_cells.append(idx)
			
		# Overload limit handling
		while _cells.size() > max_cells:
			var oldest = _cells[0]
			_cells.remove_at(0)
			if grid._arc[oldest] == runner_id:
				grid._arc[oldest] = 255

func clear() -> void:
	for idx in _cells:
		if grid._arc[idx] == runner_id:
			grid._arc[idx] = 255
	_cells.clear()

func length() -> int:
	return _cells.size()

func contains(idx: int) -> bool:
	for c in _cells:
		if c == idx:
			return true
	return false
