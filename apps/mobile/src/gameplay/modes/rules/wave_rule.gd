class_name WaveRule
extends Node

var current_wave: int = 1
var time_to_next_wave: float = 30.0

func _process(delta: float) -> void:
	time_to_next_wave -= delta
	if time_to_next_wave <= 0:
		_spawn_wave()
		time_to_next_wave = 30.0

func _spawn_wave() -> void:
	current_wave += 1
	# Increase difficulty by spawning harder bot profiles, but never increase speed.
