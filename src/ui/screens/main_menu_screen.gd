class_name MainMenuScreen
extends Screen

signal play_requested
signal settings_requested

func on_pushed(args: Dictionary = {}) -> void:
	# Add play button with tr("menu_play")
	pass

func _on_play_pressed() -> void:
	play_requested.emit()
