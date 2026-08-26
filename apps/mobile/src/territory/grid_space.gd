class_name GridSpace
extends RefCounted

var cell_size: float = 32.0

func _init(size: float = 32.0) -> void:
	cell_size = size

func world_to_cell(world_pos: Vector2) -> Vector2i:
	var cx = int(floor(world_pos.x / cell_size))
	var cy = int(floor(world_pos.y / cell_size))
	return Vector2i(cx, cy)

func cell_to_world_center(cell: Vector2i) -> Vector2:
	return Vector2((cell.x + 0.5) * cell_size, (cell.y + 0.5) * cell_size)

func cell_rect(cell: Vector2i) -> Rect2:
	return Rect2(float(cell.x) * cell_size, float(cell.y) * cell_size, cell_size, cell_size)
