class_name ProgressionBridge
extends Node

var profile_repo: ProfileRepository
var xp_service: XpService
var stats_service: StatsService
var wallet: Wallet

func on_match_ended(result: MatchResult) -> void:
	var p := profile_repo.get_profile()
	
	# Determine if local user won (assuming local user is always id 0 for this mock)
	var is_winner := result.winner_id == 0
	
	# Stub stats
	stats_service.add_match_result(result, is_winner, 5, 2, 100)
	
	# Grant XP
	xp_service.add_xp(p, 500 if is_winner else 150)
	
	# Grant Sparks
	wallet.add_sparks(50 if is_winner else 10, "match")
	
	profile_repo.save_profile(p)
