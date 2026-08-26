class_name ResetPulseRule
extends Node

var time_to_pulse: float = 120.0

func _process(delta: float) -> void:
	time_to_pulse -= delta
	if time_to_pulse <= 5.0:
		# Show warning
		pass
	if time_to_pulse <= 0.0:
		_execute_pulse()
		time_to_pulse = 120.0

func _execute_pulse() -> void:
	# Neuter the oldest cells of anyone over 45% to prevent grid memory exhaustion
	pass
