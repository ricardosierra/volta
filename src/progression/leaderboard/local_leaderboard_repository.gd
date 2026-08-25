class_name LocalLeaderboardRepository
extends LeaderboardRepository

var _cache: Dictionary = {}

func save_score(mode: String, score: int, details: Dictionary) -> void:
	if not _cache.has(mode):
		_cache[mode] = []
	
	_cache[mode].append({"score": score, "details": details, "date": Time.get_datetime_string_from_system()})
	_cache[mode].sort_custom(func(a, b): return a.score > b.score)
	
	if _cache[mode].size() > 20:
		_cache[mode] = _cache[mode].slice(0, 20)
		
	# In a full implementation, persist to disk here via SaveService

func get_top_scores(mode: String, limit: int = 20) -> Array:
	if _cache.has(mode):
		return _cache[mode].slice(0, limit)
	return []
