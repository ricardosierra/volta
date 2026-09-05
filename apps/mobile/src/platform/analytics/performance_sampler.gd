class_name PerformanceSampler
extends Node

var analytics: RemoteAnalytics
var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer >= 15.0:
		timer = 0.0
		_sample()
		
func _sample() -> void:
	var fps := Engine.get_frames_per_second()
	var mem := OS.get_static_memory_usage() / 1024 / 1024 # MB
	
	analytics.log_event("perf_sample", {
		"fps": fps,
		"memory_mb": mem
	})
