class_name CloudSaveService
extends Node

var api: ApiClient

func _init(api_client: ApiClient) -> void:
	api = api_client

func sync_up(state: Dictionary) -> void:
	api.post("/save", {"version": 1, "state": state})
	
func sync_down() -> void:
	api.get_data("/save")
