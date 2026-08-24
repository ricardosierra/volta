class_name ServiceRegistry
extends RefCounted

## Registro de serviços sem singleton mágico (docs/architecture/overview.md §4). Bootstrap
## monta o grafo e injeta por construtor/setup(); resolve() de um serviço inexistente falha
## com erro legível, nunca com null silencioso sem explicação.

var _services: Dictionary = {}
var _last_error: String = ""


func register(service_name: String, instance: Object) -> bool:
	if _services.has(service_name):
		_last_error = "service_already_registered:%s" % service_name
		push_error("ServiceRegistry: '%s' já registrado" % service_name)
		return false
	_services[service_name] = instance
	return true


func resolve(service_name: String) -> Object:
	if not _services.has(service_name):
		_last_error = "service_not_found:%s" % service_name
		push_error("ServiceRegistry: serviço '%s' não encontrado. Registrados: %s" % [service_name, _services.keys()])
		return null
	return _services[service_name]


func has(service_name: String) -> bool:
	return _services.has(service_name)


func get_last_error() -> String:
	return _last_error
