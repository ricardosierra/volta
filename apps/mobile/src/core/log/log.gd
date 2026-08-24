# Autoload "Log" (project.godot). Sem class_name: Godot 4.3 rejeita class_name igual ao
# nome de um autoload ("Parse Error: Class 'Log' hides an autoload singleton.").
extends Node

## Logging estruturado por categoria e nível (docs/architecture/logging.md). Mensagem é uma
## chave estável em snake_case; dados vão no dicionário. Nada é montado quando o nível está
## desabilitado — ver enabled().

const Category := LogCategory.Category

enum Level { DEBUG, INFO, WARN, ERROR }

var _min_level: Dictionary = {}
var _sinks: Array[LogSink] = []


func _ready() -> void:
	for cat in Category.values():
		_min_level[cat] = Level.INFO
	_sinks.append(FileLogSink.new())


func set_min_level(category: int, level: int) -> void:
	_min_level[category] = level


func enabled(category: int, level: int) -> bool:
	if level == Level.DEBUG and not Build.is_debug():
		return false
	return level >= _min_level.get(category, Level.INFO)


func debug(category: int, key: String, data: Dictionary = {}) -> void:
	_log(category, Level.DEBUG, key, data)


func info(category: int, key: String, data: Dictionary = {}) -> void:
	_log(category, Level.INFO, key, data)


func warn(category: int, key: String, data: Dictionary = {}) -> void:
	_log(category, Level.WARN, key, data)


func error(category: int, key: String, data: Dictionary = {}) -> void:
	_log(category, Level.ERROR, key, data)


## Usado só por testes, para injetar um spy sem tocar disco.
func _set_sinks_for_test(sinks: Array[LogSink]) -> void:
	_sinks = sinks


func _log(category: int, level: int, key: String, data: Dictionary) -> void:
	if not enabled(category, level):
		return
	if Build.is_debug():
		print("[%s] %s %s" % [Level.keys()[level], key, data])
	for sink in _sinks:
		sink.write(category, level, key, data)
