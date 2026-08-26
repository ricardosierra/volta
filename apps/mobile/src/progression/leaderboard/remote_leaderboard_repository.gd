class_name RemoteLeaderboardRepository
extends LeaderboardRepository

var api: ApiClient
var cache: Dictionary = {}

func _init(api_client: ApiClient) -> void:
	api = api_client

func get_leaderboard(board_id: String) -> Array:
	if cache.has(board_id):
		return cache[board_id]
		
	api.get_data("/leaderboards/" + board_id)
	return [] # Will populate async

func submit_score(board_id: String, score: int, metadata: Dictionary = {}) -> void:
	api.post("/matches", {
		"mode": board_id,
		"score": score,
		"metadata": metadata
	}, UUID.v4())
