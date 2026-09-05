class_name ApiClient
extends Node

var base_url: String = "http://localhost:8000/api"
var auth_token: String = ""

signal request_completed(endpoint: String, response_code: int, data: Dictionary)

func post(endpoint: String, payload: Dictionary, idempotency_key: String = "") -> void:
	var http := HTTPRequest.new()
	add_child(http)
	
	var headers := ["Content-Type: application/json", "Accept: application/json"]
	if auth_token != "":
		headers.append("Authorization: Bearer " + auth_token)
	if idempotency_key != "":
		headers.append("Idempotency-Key: " + idempotency_key)
		
	http.request_completed.connect(self._on_request_completed.bind(http, endpoint))
	http.request(base_url + endpoint, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))

func get_data(endpoint: String) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	
	var headers := ["Accept: application/json"]
	if auth_token != "":
		headers.append("Authorization: Bearer " + auth_token)
		
	http.request_completed.connect(self._on_request_completed.bind(http, endpoint))
	http.request(base_url + endpoint, headers, HTTPClient.METHOD_GET)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest, endpoint: String) -> void:
	http.queue_free()
	
	var data := {}
	if response_code >= 200 and response_code < 300:
		var json := JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			data = json.get_data()
			
	request_completed.emit(endpoint, response_code, data)
