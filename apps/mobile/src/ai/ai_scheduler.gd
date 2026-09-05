class_name AIScheduler
extends Node

var bots: Array = [] # Contains dictionaries with runner and brain
var current_idx: int = 0
var max_evals_per_tick: int = 2

func register_bot(runner: Runner, brain: BotBrain) -> void:
	bots.append({"runner": runner, "brain": brain})

func tick(delta: float, grid: TerritoryGrid) -> void:
	if bots.is_empty():
		return
		
	var evals := 0
	while evals < max_evals_per_tick and evals < bots.size():
		var b: Dictionary = bots[current_idx]
		# Run brain logic, skipping for brevity of stub simulation
		# In full implementation, it feeds runner.set_desired_direction()
		
		current_idx = (current_idx + 1) % bots.size()
		evals += 1
