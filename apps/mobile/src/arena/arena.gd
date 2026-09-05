class_name Arena
extends RefCounted

var definition: ArenaDefinition
var limits: Rect2

func _init(def: ArenaDefinition) -> void:
	definition = def
	limits = Rect2(Vector2.ZERO, def.get_pixel_size())

func resolve_boundaries(runner_state: RunnerState) -> void:
	var pos := runner_state.position
	
	if pos.x < limits.position.x:
		runner_state.position.x = limits.position.x
		if runner_state.velocity.x < 0:
			runner_state.velocity.x = 0
	elif pos.x > limits.end.x:
		runner_state.position.x = limits.end.x
		if runner_state.velocity.x > 0:
			runner_state.velocity.x = 0
			
	if pos.y < limits.position.y:
		runner_state.position.y = limits.position.y
		if runner_state.velocity.y < 0:
			runner_state.velocity.y = 0
	elif pos.y > limits.end.y:
		runner_state.position.y = limits.end.y
		if runner_state.velocity.y > 0:
			runner_state.velocity.y = 0
