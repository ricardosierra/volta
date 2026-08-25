class_name PauseScreen
extends Screen

signal resume_requested
signal restart_requested
signal settings_requested
signal quit_requested

func on_pushed(args: Dictionary = {}) -> void:
	get_tree().paused = true

func on_popped() -> void:
	get_tree().paused = false

func handle_back_button() -> bool:
	resume_requested.emit()
	return true
