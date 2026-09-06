class_name RemoteLeaderboardRepository
extends LeaderboardRepository

var api: ApiClient
var cache: Dictionary = {}

func _init(api_client: ApiClient) -> void:
	api = api_client

func get_leaderboard(board_id: String) -> Array:
	if cache.has(board_id):
		return cache[board_id]
		
	api.get_data("/leaderboards/" + board_id)
	return [] # Will populate async

func submit_score(board_id: String, score: int, metadata: Dictionary = {}) -> void:
	api.post("/matches", {
		"mode": board_id,
		"score": score,
		"metadata": metadata
	}, _generate_idempotency_key())


## UUID.v4() referenciava uma classe que nunca existiu no projeto e quebrava a compilacao do
## arquivo inteiro — mesmo bug ja corrigido em remote_profile_repository.gd na Fase 26.1.
## Gera a chave localmente (RFC 4122 v4) sem introduzir classe compartilhada nova.
func _generate_idempotency_key() -> String:
	var bytes := PackedByteArray()
	for i in range(16):
		bytes.append(randi() % 256)
	bytes[6] = (bytes[6] & 0x0F) | 0x40
	bytes[8] = (bytes[8] & 0x3F) | 0x80
	var hex := ""
	for b in bytes:
		hex += "%02x" % b
	return "%s-%s-%s-%s-%s" % [hex.substr(0, 8), hex.substr(8, 4), hex.substr(12, 4), hex.substr(16, 4), hex.substr(20, 12)]
