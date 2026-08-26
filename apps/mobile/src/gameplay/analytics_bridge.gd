class_name AnalyticsBridge
extends Node

var service: AnalyticsService

func _init(s: AnalyticsService) -> void:
	service = s

func on_match_started(mode: String) -> void:
	service.log_event("match_started", {"mode": mode})

func on_match_ended(result: MatchResult) -> void:
	service.log_event("match_ended", {
		"cause": result.cause,
		"winner_id": result.winner_id,
		"duration": result.match_time
	})

func on_runner_eliminated(victim: int, killer: int, cause: String) -> void:
	service.log_event("runner_eliminated", {
		"victim": victim,
		"killer": killer,
		"cause": cause
	})
