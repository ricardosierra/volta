class_name SkinsScreen
extends Screen

# Shows grid of cosmetic items of a certain type

func on_pushed(args: Dictionary = {}) -> void:
	# Filter catalog by args["type"]
	pass

func _on_item_pressed(item_id: String) -> void:
	# If owned -> Equip
	# If not owned -> Attempt purchase via UnlockService
	pass
