class_name FileSaveService
extends SaveService

## Implementação em disco de SaveService (docs/architecture/save-system.md §3 e §5).
## `profile.json` e `settings.json` são arquivos INDEPENDENTES: mesma escrita atômica
## (tmp → flush → backup → rename) e mesma recuperação de corrupção em 2 níveis (backup, depois
## recriação preservando os arquivos suspeitos como `.corrupt-<timestamp>`, nunca apagando),
## aplicadas separadamente a cada um — corrupção de perfil nunca leva as settings junto (ADR-0003).
## `SaveResult` é herdado de SaveService.SaveResult (OK/RESTORED_FROM_BACKUP/RECREATED).
##
## `mark_dirty()` só marca a seção como pendente; QUANDO gravar (fim de partida, pause,
## NOTIFICATION_APPLICATION_PAUSED, timer de 60s) é decisão do consumidor, não deste serviço —
## isso requer um Node vivo na árvore de cena, que só existe a partir do Bootstrap (Plano 01-10).

var save_dir: String = "user://save/"
var data: SaveData = SaveData.new()
var migrations: Array[SaveMigration] = []
var _dirty: Dictionary = {}


func _init(dir: String = "user://save/") -> void:
	save_dir = dir


func register_migration(migration: SaveMigration) -> void:
	migrations.append(migration)


func load_profile() -> SaveResult:
	var previous_settings: Dictionary = data.settings.duplicate(true)
	var loaded := _load_with_recovery("profile.json")
	var result: SaveResult = loaded["result"]
	if result == SaveResult.RECREATED:
		data = SaveData.new()
		data.settings = previous_settings
		save_profile(true)
		return result
	var raw: Dictionary = _run_migrations(loaded["data"])
	data = SaveData.from_dict(raw)
	data.settings = previous_settings
	return result


func save_profile(now: bool = false) -> void:
	_write_atomic("profile.json", data.to_dict())
	_dirty.clear()


func load_settings() -> SaveResult:
	var loaded := _load_with_recovery("settings.json")
	var result: SaveResult = loaded["result"]
	if result == SaveResult.RECREATED:
		data.settings = {}
		save_settings()
		return result
	data.apply_settings_dict(loaded["data"])
	return result


func save_settings() -> void:
	_write_atomic("settings.json", data.settings_to_dict())


func mark_dirty(section: StringName) -> void:
	_dirty[section] = true


func _run_migrations(raw: Dictionary) -> Dictionary:
	var current := raw
	while true:
		var meta: Dictionary = current.get("meta", {})
		var version: int = int(meta.get("schema_version", SaveData.CURRENT_SCHEMA_VERSION))
		var next: Array = migrations.filter(func(m: SaveMigration) -> bool: return m.from_version() == version)
		if next.is_empty():
			break
		current = next[0].migrate(current)
	return current


## Serializa `payload` e grava em `<save_dir>/<file_name>` de forma atômica: escreve em
## `<file_name>.tmp`, flush, copia o arquivo principal atual (se existir e for JSON válido) para
## `<file_name>.bak`, e só então renomeia `.tmp` → arquivo final. `_write_atomic` é usado para
## profile.json E settings.json — arquivos independentes, mesma primitiva.
func _write_atomic(file_name: String, payload: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(save_dir)
	var path := save_dir.path_join(file_name)
	var tmp_path := path + ".tmp"
	var bak_path := path + ".bak"

	var tmp_file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if tmp_file == null:
		push_error("FileSaveService: falha ao abrir %s (erro %d)" % [tmp_path, FileAccess.get_open_error()])
		return
	tmp_file.store_string(JSON.stringify(payload, "  "))
	tmp_file.flush()
	tmp_file.close()

	if _try_parse(path)["valid"]:
		var current_file := FileAccess.open(path, FileAccess.READ)
		var current_text := current_file.get_as_text()
		current_file.close()
		var bak_file := FileAccess.open(bak_path, FileAccess.WRITE)
		if bak_file != null:
			bak_file.store_string(current_text)
			bak_file.flush()
			bak_file.close()

	var dir := DirAccess.open("user://")
	if dir == null:
		push_error("FileSaveService: não foi possível abrir user:// para renomear %s" % [tmp_path])
		return
	dir.rename(tmp_path, path)


## Carrega `<save_dir>/<file_name>` com recuperação em 2 níveis (docs/architecture/save-system.md
## §5). Devolve `{"result": SaveResult, "data": Dictionary}` (`data` vazio quando `RECREATED`).
## Nunca apaga um arquivo suspeito — sempre renomeia para `.corrupt-<timestamp>`.
func _load_with_recovery(file_name: String) -> Dictionary:
	var path := save_dir.path_join(file_name)
	var bak_path := path + ".bak"

	if not FileAccess.file_exists(path):
		return {"result": SaveResult.RECREATED, "data": {}}

	var main := _try_parse(path)
	if main["valid"]:
		return {"result": SaveResult.OK, "data": main["data"]}

	var bak := _try_parse(bak_path)
	if bak["valid"]:
		_write_atomic(file_name, bak["data"])
		return {"result": SaveResult.RESTORED_FROM_BACKUP, "data": bak["data"]}

	var timestamp: int = int(Time.get_unix_time_from_system())
	_rename_to_corrupt(path, timestamp)
	if FileAccess.file_exists(bak_path):
		_rename_to_corrupt(bak_path, timestamp)
	return {"result": SaveResult.RECREATED, "data": {}}


func _rename_to_corrupt(path: String, timestamp: int) -> void:
	var dir := DirAccess.open("user://")
	if dir == null:
		push_error("FileSaveService: não foi possível abrir user:// para preservar %s" % [path])
		return
	dir.rename(path, "%s.corrupt-%d" % [path, timestamp])


## Lê e faz parse de `path`. Devolve `{"valid": bool, "data": Dictionary}` — `valid` é false
## para arquivo ausente, ilegível, JSON sintaticamente inválido ou JSON válido que não é um
## objeto (Dictionary) no topo.
func _try_parse(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"valid": false, "data": {}}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"valid": false, "data": {}}
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"valid": false, "data": {}}
	return {"valid": true, "data": parsed}
