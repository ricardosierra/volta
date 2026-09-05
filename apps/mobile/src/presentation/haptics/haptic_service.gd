class_name HapticService
extends Node

enum Intensity { OFF, LIGHT, FULL }
var current_intensity: Intensity = Intensity.FULL

func vibrate(duration_ms: int) -> void:
	if current_intensity == Intensity.OFF: return
	
	if OS.has_feature("mobile"):
		# Vibrate device
		Input.vibrate_handheld(duration_ms)

func play_seal(area: int) -> void:
	if current_intensity == Intensity.OFF: return
	
	var duration := 50
	if area > 100: duration = 100
	if area > 200: duration = 200
	
	if current_intensity == Intensity.LIGHT:
		duration = int(duration * 0.5)
		
	vibrate(duration)

func play_break() -> void:
	if current_intensity == Intensity.OFF: return
	vibrate(300 if current_intensity == Intensity.FULL else 150)
