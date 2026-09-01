class_name RemoteProfileRepository
extends ProfileRepository

var api: ApiClient
var queue: OfflineQueue
var local_cache: LocalProfileRepository

func _init(api_client: ApiClient, offline_queue: OfflineQueue, cache: LocalProfileRepository) -> void:
	api = api_client
	queue = offline_queue
	local_cache = cache

func load_profile() -> Profile:
	# Optimistically return local, but fetch in background
	if api != null:
		api.get_data("/profile")
	return local_cache.get_profile()

func save_profile(profile: Profile) -> void:
	local_cache.save_profile(profile)
	queue.enqueue("/profile", "PATCH", {"nickname": profile.nickname}, _generate_idempotency_key())

## Bug pre-existente achado na auditoria da Fase 26 (Plano 26.1-05): esta chamada usava
## UUID.v4(), uma classe que nunca existiu no projeto, e quebrava a compilacao do arquivo
## inteiro. Gera a chave de idempotencia localmente (RFC 4122 v4) sem introduzir uma nova
## classe compartilhada, pois ligar OfflineQueue/ApiClient de verdade e trabalho de outra fase.
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
