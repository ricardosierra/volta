class_name State
extends RefCounted

## Called when the state is entered
func enter() -> void:
	pass

## Called when the state is exited
func exit() -> void:
	pass

## Called every simulation tick while this state is active
func update(_delta: float) -> void:
	pass
