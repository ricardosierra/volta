class_name GridSerializer
extends RefCounted

static func serialize(grid: TerritoryGrid) -> PackedByteArray:
	return grid._owner

static func deserialize(grid: TerritoryGrid, data: PackedByteArray) -> void:
	grid._owner = data
