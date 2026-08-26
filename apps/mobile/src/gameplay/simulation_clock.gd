class_name SimulationClock
extends RefCounted

var current_tick: int = 0
var seed_value: int = 0

func _init(initial_seed: int = 0) -> void:
	seed_value = initial_seed
	current_tick = 0

func advance() -> void:
	current_tick += 1

func reset(new_seed: int) -> void:
	seed_value = new_seed
	current_tick = 0
