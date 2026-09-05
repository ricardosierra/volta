class_name StatBlock
extends RefCounted

## Estatísticas resolvidas de um Runner. base_speed/base_turn_rate vêm SEMPRE de um
## RunnerBalance (docs/design/balance.md §2, packages/shared/config/balance/runner.tres) —
## nunca de um literal aqui (CLAUDE.md regra 4). Sem balance explícito, usa
## RunnerBalance.new(), cujos defaults tipados JÁ são os valores de balance.md
## (core/config/runner_balance.gd) — não duplicamos o número numa segunda classe.

var base_speed: float
var base_turn_rate: float
var speed_multiplier: float = 1.0

var _speed_modifiers: Array[float] = []
var _turn_rate_modifiers: Array[float] = []

func _init(balance: RunnerBalance = null) -> void:
	var b: RunnerBalance = balance if balance else RunnerBalance.new()
	base_speed = b.base_speed
	base_turn_rate = b.turn_rate

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
