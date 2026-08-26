class_name CharacterScreen
extends Screen

# Shows current loadout and preview

func on_pushed(args: Dictionary = {}) -> void:
	# Show RunnerView preview
	pass

func _on_slot_pressed(type: CosmeticItem.Type) -> void:
	# Navigate to SkinsScreen, passing the slot type
	pass
