class_name RemoteProfileRepository
extends ProfileRepository

var api: ApiClient
var queue: OfflineQueue
var local_cache: LocalProfileRepository

func _init(api_client: ApiClient, offline_queue: OfflineQueue, cache: LocalProfileRepository) -> void:
	api = api_client
	queue = offline_queue
	local_cache = cache

func load_profile() -> Profile:
	# Optimistically return local, but fetch in background
	api.get_data("/profile")
	return local_cache.load_profile()

func save_profile(profile: Profile) -> void:
	local_cache.save_profile(profile)
	queue.enqueue("/profile", "PATCH", {"nickname": profile.nickname}, UUID.v4())
