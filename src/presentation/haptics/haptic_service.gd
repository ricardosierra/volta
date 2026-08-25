class_name HapticService
extends Node

enum Intensity { OFF, LIGHT, FULL }
var current_intensity: Intensity = Intensity.FULL

func vibrate(duration_ms: int) -> void:
	if current_intensity == Intensity.OFF: return
	
	if OS.has_feature("mobile"):
		# Vibrate device
		Input.vibrate_handheld(duration_ms)
