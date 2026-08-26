class_name SfxService
extends Node

var max_concurrent_sounds: int = 3
# Internal pool of AudioStreamPlayer could be implemented here

func play_seal(area: int) -> void:
	# Randomize pitch 0.97 to 1.03
	pass

func play_break() -> void:
	pass

func play_backwash() -> void:
	pass

func _ready() -> void:
	# Configure AudioServer for iOS interruptions
	# In Godot 4, iOS audio routing handles this largely automatically
	# but we can subscribe to changes if needed.
	pass
