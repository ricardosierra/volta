class_name TimeBonusRule
extends Node

var director: MatchDirector

func _ready() -> void:
	# Assume injected or we find it
	pass

func on_seal(runner_id: int, area: int) -> void:
	if runner_id == 0: # Local player
		var bonus = clamp(2.0 + (area * 0.4), 0.0, 8.0)
		director.time_limit_sec += bonus
		# Emit signal for HUD
