class_name ArenaDefinition
extends Resource

@export var id: String = "standard"
@export var name: String = "Standard Arena"
@export var width_cells: int = 128
@export var height_cells: int = 128
@export var cell_size: float = 16.0
@export var spawn_points: Array[Vector2] = []
@export var blocked_rects: Array[Rect2] = []
@export var hazard_rects: Array[Rect2] = []

func get_pixel_size() -> Vector2:
	return Vector2(float(width_cells) * cell_size, float(height_cells) * cell_size)

func is_blocked(pos: Vector2) -> bool:
	for r in blocked_rects:
		if r.has_point(pos):
			return true
	return false

func is_hazard(pos: Vector2) -> bool:
	for r in hazard_rects:
		if r.has_point(pos):
			return true
	return false

func is_valid() -> bool:
	# Mock validation: ensure at least some playable area and spawns
	if spawn_points.is_empty():
		return false
	return true
