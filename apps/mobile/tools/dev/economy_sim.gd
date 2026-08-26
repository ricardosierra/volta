@tool
extends SceneTree

# Usage: godot --headless -s tools/dev/economy_sim.gd

func _init() -> void:
	print("--- Running Economy Simulation (30 Days) ---")
	
	var sparks = 0
	var days = 30
	var matches_per_day = 5 # Casual player
	
	for d in range(days):
		# Daily challenge reward
		sparks += 100 
		for m in range(matches_per_day):
			var win = randf() > 0.5
			sparks += (50 if win else 15)
			
	print("Casual Player (5 matches/day, 50% winrate) after 30 days:")
	print("Total Sparks: ", sparks)
	print("Average Sparks/Day: ", sparks / days)
	
	quit()
