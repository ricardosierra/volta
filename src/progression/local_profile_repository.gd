class_name LocalProfileRepository
extends ProfileRepository

var _cache: Profile

func get_profile() -> Profile:
	if not _cache:
		_cache = Profile.new()
		_cache.player_id = "local_user_1"
		_cache.nickname = "Guest_" + str(randi() % 9999)
	return _cache

func save_profile(p: Profile) -> void:
	_cache = p
	# Persistence via SaveService handled here
