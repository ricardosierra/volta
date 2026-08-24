class_name Build
extends RefCounted

const FLAGS_PATH: String = "res://resources/build_flags.tres"

static var _flags_cache: BuildFlags = null

static func is_debug() -> bool:
	return _compute_is_debug(OS.is_debug_build(), _get_flags().debug_tools_enabled)


static func version() -> String:
	return ProjectSettings.get_setting("application/config/version", "0.0.0")


static func commit() -> String:
	return _get_flags().commit_sha


static func env() -> String:
	if OS.has_environment("VOLTA_ENV"):
		return OS.get_environment("VOLTA_ENV")
	return "development"


static func _compute_is_debug(os_debug: bool, flags_enabled: bool) -> bool:
	return os_debug and flags_enabled


static func _get_flags() -> BuildFlags:
	if _flags_cache == null:
		var loaded: Resource = ResourceLoader.load(FLAGS_PATH)
		_flags_cache = loaded as BuildFlags
		if _flags_cache == null:
			_flags_cache = BuildFlags.new()
	return _flags_cache
