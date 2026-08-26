class_name MatchRules
extends Resource

enum WinCondition {
	TIME,
	DOMINATION,
	SURVIVAL,
	ENDLESS
}

@export var id: String = "classic"
@export var name: String = "Classic"
@export var time_limit_sec: float = 180.0
@export var bot_count: int = 3
@export var player_respawn: bool = true
@export var respawn_delay_sec: float = 2.0
@export var win_condition: WinCondition = WinCondition.TIME
@export var domination_target: float = 0.5
@export var rules: Array[Script] = []
