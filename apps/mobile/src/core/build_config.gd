class_name BuildConfig
extends Object

static func is_debug() -> bool:
	return OS.is_debug_build()

static func enable_dev_tools() -> bool:
	return is_debug() and OS.get_environment("VOLTA_DEBUG_TOOLS") != "false"
