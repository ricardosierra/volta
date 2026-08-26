class_name StatBlock
extends RefCounted

var speed_multiplier: float = 1.0

var base_speed: float = 300.0
var base_turn_rate: float = 180.0 # Degrees per second

var _speed_modifiers: Array[float] = []
var _turn_rate_modifiers: Array[float] = []

func add_speed_modifier(value: float) -> void:
	_speed_modifiers.append(value)

func remove_speed_modifier(value: float) -> void:
	var idx = _speed_modifiers.find(value)
	if idx != -1:
		_speed_modifiers.remove_at(idx)

func add_turn_rate_modifier(value: float) -> void:
	_turn_rate_modifiers.append(value)

func remove_turn_rate_modifier(value: float) -> void:
	var idx = _turn_rate_modifiers.find(value)
	if idx != -1:
		_turn_rate_modifiers.remove_at(idx)

func get_speed() -> float:
	var s = base_speed
	for m in _speed_modifiers:
		s += m
	return maxf(0.0, s)

func get_turn_rate() -> float:
	var tr = base_turn_rate
	for m in _turn_rate_modifiers:
		tr += m
	return maxf(0.0, tr)
