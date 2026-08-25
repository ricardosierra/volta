class_name ArenaDefinition
extends Resource

@export var width_cells: int = 100
@export var height_cells: int = 100
@export var cell_size: float = 32.0

@export var spawn_points: Array[Vector2] = []
@export var blocked_cells: Array[Vector2i] = []

func get_pixel_size() -> Vector2:
	return Vector2(width_cells * cell_size, height_cells * cell_size)
