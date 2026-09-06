class_name Profiler
extends Node

var timers: Dictionary = {}

func start(region: String) -> void:
	timers[region] = Time.get_ticks_usec()
	
func stop(region: String) -> void:
	if timers.has(region):
		var elapsed: int = Time.get_ticks_usec() - timers[region]
		# Accumulate or print elapsed time for region
		pass
