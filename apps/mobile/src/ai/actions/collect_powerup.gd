class_name CollectPowerupAction
extends Node

func score_action(runner: Runner, orbs: Array[Vector2]) -> float:
	if orbs.is_empty():
		return 0.0
	
	var closest = INF
	for o in orbs:
		var d = runner.state.position.distance_to(o)
		if d < closest:
			closest = d
			
	if closest < 300.0:
		return 50.0 / max(1.0, closest)
	return 0.0
