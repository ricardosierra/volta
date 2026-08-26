class_name CrashReporter
extends Node

var analytics: RemoteAnalytics

func _ready() -> void:
	# Hook into engine errors if possible (Godot 4 usually prints to console, 
	# but we can capture panics/asserts if configured)
	pass
	
func report_crash(stack_trace: String, context: Dictionary) -> void:
	analytics.log_event("app_crash", {
		"stack": stack_trace,
		"context": context
	})
