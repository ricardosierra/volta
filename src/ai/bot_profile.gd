class_name BotProfile
extends Resource

@export var difficulty_level: String = "rookie"
@export var reaction_delay_ms: float = 300.0
@export var error_rate: float = 0.2

@export var weight_expand_frontier: float = 1.0
@export var weight_expand_deep: float = 1.0
@export var weight_steal_from: float = 0.5
@export var weight_intercept: float = 0.2
@export var weight_flee_home: float = 1.5
@export var weight_seal_now: float = 2.0
@export var weight_patrol_border: float = 0.5
