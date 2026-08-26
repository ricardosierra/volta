class_name Catalog
extends Node

var items: Dictionary = {}

func load_all(directory: String = "res://resources/cosmetics/") -> void:
	# Mock loading since actual scanning in GDScript needs EditorFileSystem or fixed arrays
	pass

func get_item(id: String) -> CosmeticItem:
	return items.get(id)
