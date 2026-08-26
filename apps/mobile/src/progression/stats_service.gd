class_name StatsService
extends Node

var total_kills: int = 0
var total_deaths: int = 0
var total_matches: int = 0
var total_wins: int = 0
var total_captures: int = 0
var playtime_seconds: float = 0.0

func add_match_result(result: MatchResult, is_winner: bool, kills: int, deaths: int, captures: int) -> void:
	total_matches += 1
	if is_winner: total_wins += 1
	total_kills += kills
	total_deaths += deaths
	total_captures += captures
	playtime_seconds += result.match_time

func get_kd_ratio() -> float:
	if total_deaths == 0: return float(total_kills)
	return float(total_kills) / float(total_deaths)

func get_winrate() -> float:
	if total_matches == 0: return 0.0
	return float(total_wins) / float(total_matches)
