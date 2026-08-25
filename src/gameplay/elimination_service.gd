class_name EliminationService
extends RefCounted

signal runner_eliminated(victim: int, killer: int, cause: String)

func handle_break(victim: int, killer: int, grid: TerritoryGrid, tracker: ArcTracker) -> void:
	# Release claim and clear arc
	grid.release_claim(victim)
	tracker.clear()
	
	# Emit event
	runner_eliminated.emit(victim, killer, "break")

func handle_squeeze(victim: int, killer: int, grid: TerritoryGrid, tracker: ArcTracker) -> void:
	grid.release_claim(victim)
	tracker.clear()
	runner_eliminated.emit(victim, killer, "squeeze")
