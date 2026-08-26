class_name AdaptiveMusic
extends Node

var current_intensity: float = 0.0

# 6 layers of music
var base_layer: AudioStreamPlayer
var rhythm_layer: AudioStreamPlayer
var tension_layer: AudioStreamPlayer

func update_intensity(highest_threat_distance: float, time_left: float) -> void:
	# Crossfade layers based on tension
	if time_left < 30.0:
		# Final Push layer
		pass
