class_name VButton
extends Button

# Basic UI Component mapped to tokens

func _ready() -> void:
	custom_minimum_size = Vector2(0, 48) # Minimum touch target
	# Theme overrides would be applied here from ThemeService
	
func _pressed() -> void:
	# Trigger haptic via HapticService
	pass
