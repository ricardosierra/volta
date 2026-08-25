class_name Screen
extends Control

signal back_requested

func on_pushed(args: Dictionary = {}) -> void:
	pass

func on_popped() -> void:
	pass

func on_focus_gained() -> void:
	pass

func on_focus_lost() -> void:
	pass

func handle_back_button() -> bool:
	return false # Return true if handled internally
