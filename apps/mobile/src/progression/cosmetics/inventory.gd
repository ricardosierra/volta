class_name Inventory
extends RefCounted

var owned_ids: Array[String] = []

func has_item(id: String) -> bool:
	return id in owned_ids

func add_item(id: String) -> void:
	if not has_item(id):
		owned_ids.append(id)
