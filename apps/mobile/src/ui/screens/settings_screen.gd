class_name SettingsScreen
extends Screen

# Contains UI for Audio, Controls, Graphics, Accessibility

func on_pushed(args: Dictionary = {}) -> void:
	# Load from SaveService and populate sliders
	pass

func _on_audio_slider_changed(value: float) -> void:
	# Update AudioServer and save
	pass
