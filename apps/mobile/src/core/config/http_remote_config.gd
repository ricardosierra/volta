class_name HttpRemoteConfig
extends Node

var api: ApiClient
var current_etag: String = ""
var config_data: Dictionary = {}

func fetch_config() -> void:
	api.get_data("/config")
	# Logic to pass If-None-Match would go in ApiClient
	
func get_value(key: String, default_val: Variant) -> Variant:
	if config_data.has(key):
		return config_data[key]
	return default_val
