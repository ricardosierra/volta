class_name OfflineQueue
extends Node

var queue: Array[Dictionary] = []
var file_path: String = "user://offline_queue.json"

func _ready() -> void:
	_load_queue()

func enqueue(endpoint: String, method: String, payload: Dictionary, idempotency_key: String) -> void:
	queue.append({
		"endpoint": endpoint,
		"method": method,
		"payload": payload,
		"idempotency_key": idempotency_key
	})
	_save_queue()

func _load_queue() -> void:
	if FileAccess.file_exists(file_path):
		var file := FileAccess.open(file_path, FileAccess.READ)
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var parsed: Variant = json.get_data()
			if parsed is Array:
				for item in parsed:
					queue.append(item as Dictionary)

func _save_queue() -> void:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(queue))
