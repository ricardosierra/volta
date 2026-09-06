class_name ChallengeService
extends Node

var active_challenges: Array[Challenge] = []
var last_generation_day: int = -1

func generate_if_needed() -> void:
	var current_day: int = Time.get_datetime_dict_from_system()["day"]
	if current_day != last_generation_day:
		_generate_challenges(current_day)

func _generate_challenges(seed_val: int) -> void:
	# MOCK-004: Will be remote in GSD 16
	active_challenges.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	
	for i in range(3):
		var c := Challenge.new()
		c.id = "daily_" + str(i)
		c.description = "Mock Daily " + str(i+1)
		c.target = rng.randi_range(1, 10)
		active_challenges.append(c)
		
	last_generation_day = seed_val
