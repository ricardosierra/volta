class_name PowerUpSpawner
extends Node

var orbs: Array[Vector2] = []
var time_to_spawn: float = 15.0

func tick(delta: float, runners: Array[Runner], grid: TerritoryGrid) -> void:
	time_to_spawn -= delta
	if time_to_spawn <= 0:
		_spawn_orb(runners, grid)
		time_to_spawn = randf_range(10.0, 25.0)
		
	_check_collection(runners)

func _spawn_orb(runners: Array[Runner], grid: TerritoryGrid) -> void:
	if orbs.size() >= 3:
		return
		
	# Find a random valid cell that is at least 300px away from all runners
	var valid_pos := Vector2.ZERO
	# In reality, this would search the grid
	orbs.append(valid_pos)

func _check_collection(runners: Array[Runner]) -> void:
	for r in runners:
		for i in range(orbs.size() - 1, -1, -1):
			if r.state.position.distance_to(orbs[i]) < 50.0:
				orbs.remove_at(i)
				# Trigger effect logic via event bus
