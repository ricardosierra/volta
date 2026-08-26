class_name SeasonService
extends Node

var current_season: Dictionary = {}

func fetch_season_config() -> void:
	# Fetch active season ID and track definitions from remote config
	current_season = {
		"id": "season_1",
		"name": "Neon Genesis",
		"free_track": ["prism_50", "skin_basic"],
		"premium_track": ["skin_epic", "prism_200"]
	}
