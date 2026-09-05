class_name RunnerState
extends RefCounted

enum State {
	SPAWN,
	SAFE,
	ELIMINATED
}

var id: int = 0
var position: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.UP
var desired_direction: Vector2 = Vector2.UP
var velocity: Vector2 = Vector2.ZERO
var fsm_state := State.SPAWN
