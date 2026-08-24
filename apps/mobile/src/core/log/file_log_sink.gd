class_name FileLogSink
extends LogSink

## Sink de log em arquivo, com rotação por tamanho. Grava em user://logs/, no máximo
## MAX_FILES arquivos de até MAX_BYTES cada; o arquivo mais antigo além do teto é descartado
## a cada rotação (shift de índices).

const MAX_BYTES: int = 2 * 1024 * 1024
const MAX_FILES: int = 5
const LOG_DIR: String = "user://logs/"
const BASE_NAME: String = "volta"

var _current: FileAccess = null
var _current_size: int = 0


func write(category: int, level: int, key: String, data: Dictionary) -> void:
	_ensure_open()
	var line := "%s [%d:%d] %s %s\n" % [Time.get_datetime_string_from_system(true), category, level, key, JSON.stringify(data)]
	var bytes := line.to_utf8_buffer()
	if _current_size + bytes.size() > MAX_BYTES:
		_rotate()
	_current.store_buffer(bytes)
	_current.flush()
	_current_size += bytes.size()


func _ensure_open() -> void:
	if _current != null:
		return
	DirAccess.make_dir_recursive_absolute(LOG_DIR)
	var path := "%s%s_0.log" % [LOG_DIR, BASE_NAME]
	_current = FileAccess.open(path, FileAccess.READ_WRITE if FileAccess.file_exists(path) else FileAccess.WRITE)
	if _current == null:
		_current = FileAccess.open(path, FileAccess.WRITE)
	_current.seek_end()
	_current_size = _current.get_length()


func _rotate() -> void:
	_current.close()
	var dir := DirAccess.open(LOG_DIR)
	var oldest := "%s%s_%d.log" % [LOG_DIR, BASE_NAME, MAX_FILES - 1]
	if FileAccess.file_exists(oldest):
		dir.remove(oldest)
	for i in range(MAX_FILES - 2, -1, -1):
		var src := "%s%s_%d.log" % [LOG_DIR, BASE_NAME, i]
		var dst := "%s%s_%d.log" % [LOG_DIR, BASE_NAME, i + 1]
		if FileAccess.file_exists(src):
			dir.rename(src, dst)
	_current = FileAccess.open("%s%s_0.log" % [LOG_DIR, BASE_NAME], FileAccess.WRITE)
	_current_size = 0
