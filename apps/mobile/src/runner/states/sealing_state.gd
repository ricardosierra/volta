class_name SealingState
extends State

var runner: Runner

func _init(r: Runner):
	runner = r

func enter() -> void:
	# Synchronous transition, solved and immediately back to safe
	# Logic handled by MatchDirector in tick
	pass
