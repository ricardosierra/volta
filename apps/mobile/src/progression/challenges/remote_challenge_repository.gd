class_name RemoteChallengeRepository
extends ChallengeRepository

var api: ApiClient

func _init(api_client: ApiClient) -> void:
	api = api_client

func get_daily_challenges() -> Array:
	api.get_data("/challenges/daily")
	# Fallback to local if needed
	return []
