class_name HitState
extends State

var runner: Runner

func _init(r: Runner) -> void:
	runner = r

func enter() -> void:
	runner.state.fsm_state = RunnerState.State.ELIMINATED
