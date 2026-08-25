class_name SealResult
extends RefCounted

var runner_id: int
var captured_cells: PackedInt32Array
var stolen_from_owners: Dictionary # owner_id -> count
var swallowed_arcs: Array[int]
var bounding_box: Rect2i

func _init() -> void:
	captured_cells = PackedInt32Array()
	stolen_from_owners = {}
	swallowed_arcs = []
	bounding_box = Rect2i()
