class_name BotSafety
extends RefCounted

func evaluate_risk(pos: Vector2, arena: ArenaDefinition) -> float:
	var risk := 0.0
	if arena:
		if arena.is_hazard(pos):
			risk += 10.0 # Extreme risk
		if arena.is_blocked(pos):
			risk += 5.0
	return risk
