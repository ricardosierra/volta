class_name RemoteAnalytics
extends Node

var api: ApiClient
var batch: Array[Dictionary] = []
var consent_given: bool = true

func log_event(event_name: String, params: Dictionary = {}) -> void:
	if not consent_given:
		return
		
	batch.append({
		"name": event_name,
		"params": params,
		"ts": Time.get_unix_time_from_system()
	})
	
	if batch.size() >= 10:
		_flush()

func _flush() -> void:
	if batch.is_empty():
		return
	api.post("/telemetry", {"events": batch})
	batch.clear()
