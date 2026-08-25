class_name BotAction
extends RefCounted

var action_name: String = "base_action"

func score(ctx: Dictionary) -> float:
	return 0.0

func direction(ctx: Dictionary) -> Vector2:
	return Vector2.ZERO
