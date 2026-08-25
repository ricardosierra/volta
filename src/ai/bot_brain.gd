class_name BotBrain
extends RefCounted

var profile: BotProfile
var actions: Array[BotAction] = []
var current_action: BotAction
var hysteresis_bonus: float = 0.2

var last_decision_time: float = 0.0
var _clock: float = 0.0

func _init(prof: BotProfile) -> void:
	profile = prof
	# Initialize actions here

func decide(ctx: Dictionary, delta: float) -> Vector2:
	_clock += delta
	
	if _clock - last_decision_time < (profile.reaction_delay_ms / 1000.0):
		if current_action:
			return current_action.direction(ctx)
		return Vector2.ZERO
		
	var best_score = -1.0
	var best_action = null
	var second_best_action = null
	
	for a in actions:
		var score = a.score(ctx)
		if a == current_action:
			score += hysteresis_bonus
			
		if score > best_score:
			second_best_action = best_action
			best_action = a
			best_score = score
			
	# Error rate implementation
	if second_best_action and randf() < profile.error_rate:
		best_action = second_best_action
		
	current_action = best_action
	last_decision_time = _clock
	
	if current_action:
		return current_action.direction(ctx)
		
	return Vector2.ZERO
