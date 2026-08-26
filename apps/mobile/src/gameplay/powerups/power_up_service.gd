class_name PowerUpService
extends Node

var active_effects: Dictionary = {} # int -> PowerUpEffect

func apply_effect(runner_id: int, effect: PowerUpEffect, stats: StatBlock) -> void:
	if active_effects.has(runner_id):
		active_effects[runner_id].on_expire(stats)
		
	active_effects[runner_id] = effect
	effect.on_apply(stats)

func tick(delta: float, runners: Array[Runner]) -> void:
	for r in runners:
		var id = r.state.id
		if active_effects.has(id):
			var eff = active_effects[id]
			eff.on_tick(delta, r.stats)
			if eff.is_expired():
				eff.on_expire(r.stats)
				active_effects.erase(id)
