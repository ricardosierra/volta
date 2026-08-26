var file = FileAccess.open("apps/mobile/src/gameplay/match_director.gd", FileAccess.READ)
var content = file.get_as_text()
file.close()

var new_setup = """func setup_match(mode_config: Resource) -> void:
	ai_scheduler = AIScheduler.new()
	add_child(ai_scheduler)
	
	var cam = Camera2D.new()
	cam.position = Vector2(540, 960) # Center of screen
	add_child(cam)
	
	var bot_count = mode_config.get_meta("bot_count", 0)
	for i in range(bot_count):
		var r = Runner.new(i + 1, Vector2(100 + i*50, 100), Vector2.UP)
		runners.append(r)
		
		# Load archetype based on config
		var profile = BotProfile.new() # Default for now
		var brain = BotBrain.new(profile)
		ai_scheduler.register_bot(r, brain)
		
		# Visualization
		if ClassDB.class_exists("RunnerView"):
			var view = load("res://src/presentation/runner_view.gd").new()
			add_child(view)
			# Hack to position them just so they show up
			view.position = r.state.position
"""

content = content.replace("func setup_match(mode_config: Resource) -> void:\n\tai_scheduler = AIScheduler.new()\n\tadd_child(ai_scheduler)\n\t\n\tvar bot_count = mode_config.get_meta(\"bot_count\", 0)\n\tfor i in range(bot_count):\n\t\tvar r = Runner.new(i + 1, Vector2(100 + i*50, 100), Vector2.UP)\n\t\trunners.append(r)\n\t\t\n\t\t# Load archetype based on config\n\t\tvar profile = BotProfile.new() # Default for now\n\t\tvar brain = BotBrain.new(profile)\n\t\tai_scheduler.register_bot(r, brain)", new_setup)

var f2 = FileAccess.open("apps/mobile/src/gameplay/match_director.gd", FileAccess.WRITE)
f2.store_string(content)
f2.close()
