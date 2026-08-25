class_name Challenge
extends Resource

@export var id: String
@export var description: String
@export var target: int
@export var is_weekly: bool = false
@export var reward_sparks: int = 100

var current_progress: int = 0
var completed: bool = false
var claimed: bool = false
