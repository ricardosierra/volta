class_name NoopAnalytics
extends AnalyticsService

# MOCK-002: Replaced in GSD 18

func log_event(event_name: String, params: Dictionary = {}) -> void:
	if OS.is_debug_build():
		print("[Analytics] ", event_name, " ", params)

func set_user_property(prop_name: String, value: Variant) -> void:
	if OS.is_debug_build():
		print("[Analytics Prop] ", prop_name, "=", value)
