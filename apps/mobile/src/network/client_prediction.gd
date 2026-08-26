class_name ClientPrediction
extends RefCounted

var unacknowledged_inputs: Array[Dictionary] = []

func apply_local_input(tick: int, dir: Vector2) -> void:
	unacknowledged_inputs.append({"tick": tick, "dir": dir})
	
func reconcile_snapshot(server_tick: int, server_pos: Vector2, local_runner: Runner) -> void:
	# Filter out inputs older than server_tick
	unacknowledged_inputs = unacknowledged_inputs.filter(func(i): return i.tick > server_tick)
	
	# Snap to server pos
	local_runner.state.position = server_pos
	
	# Re-apply remaining inputs
	for input in unacknowledged_inputs:
		# Very naive re-application (real would use step() logic)
		local_runner.state.position += input.dir * (1.0 / 60.0) * local_runner.stats.speed
