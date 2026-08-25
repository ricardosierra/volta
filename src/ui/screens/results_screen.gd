class_name ResultsScreen
extends Control

signal play_again_requested

func show_results(result: MatchResult) -> void:
	show()
	# Display placements, highlight personal best, etc.

func _on_play_again_pressed() -> void:
	play_again_requested.emit()
