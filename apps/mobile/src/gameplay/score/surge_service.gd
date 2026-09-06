class_name SurgeService
extends Node

var runner_surge: Dictionary = {} # id -> level (float)
var config: Resource

signal surge_level_changed(runner_id: int, old_level: int, new_level: int)

func _init(cfg: Resource) -> void:
	config = cfg

func ensure_runner(id: int) -> void:
	if not runner_surge.has(id):
		runner_surge[id] = 0.0

func add_surge(runner_id: int, amount: float) -> void:
	ensure_runner(runner_id)
	var old: int = int(floor(runner_surge[runner_id]))
	var max_lvl: int = config.get_meta("max_level", 5)
	
	runner_surge[runner_id] = min(runner_surge[runner_id] + amount, max_lvl)
	
	var new_lvl: int = int(floor(runner_surge[runner_id]))
	if new_lvl != old:
		surge_level_changed.emit(runner_id, old, new_lvl)

func get_multiplier(runner_id: int) -> float:
	ensure_runner(runner_id)
	var lvl: int = int(floor(runner_surge[runner_id]))
	return config.get_meta("base_mult", 1.0) + (lvl * config.get_meta("level_mult_step", 0.5))

func tick(delta: float) -> void:
	var decay: float = config.get_meta("decay_rate_per_sec", 0.5) * delta
	for id in runner_surge.keys():
		var old := int(floor(runner_surge[id]))
		runner_surge[id] = max(0.0, runner_surge[id] - decay)
		var new_lvl := int(floor(runner_surge[id]))
		if new_lvl != old:
			surge_level_changed.emit(id, old, new_lvl)

func reset_surge(runner_id: int) -> void:
	ensure_runner(runner_id)
	var old := int(floor(runner_surge[runner_id]))
	runner_surge[runner_id] = 0.0
	if old != 0:
		surge_level_changed.emit(runner_id, old, 0)
