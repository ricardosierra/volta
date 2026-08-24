extends GutTest

## Testes de FileSaveService (REPO-007, docs/architecture/save-system.md §8): round-trip,
## escrita atômica interrompida, recuperação de corrupção em 2 níveis (backup, depois recriação
## preservando os arquivos suspeitos), migração encadeada fake, campo desconhecido preservado e
## separação profile/settings (settings.json nunca se perde por corrupção de perfil).
## Cada teste usa um diretório isolado sob user://test_save_<n>/, nunca o save real de
## desenvolvimento; before_each/after_each criam e limpam esse diretório.

class FakeMigrationV1ToV2 extends SaveMigration:
	func from_version() -> int:
		return 1

	func to_version() -> int:
		return 2

	func migrate(data: Dictionary) -> Dictionary:
		var out: Dictionary = data.duplicate(true)
		var player: Dictionary = out.get("player", {})
		if player.has("old_nickname_field"):
			player["nickname"] = player["old_nickname_field"]
			player.erase("old_nickname_field")
		out["player"] = player
		var meta: Dictionary = out.get("meta", {})
		meta["schema_version"] = 2
		out["meta"] = meta
		return out


var _test_dir: String = ""


func before_each() -> void:
	_test_dir = "user://test_save_%d_%d/" % [Time.get_ticks_usec(), randi()]


func after_each() -> void:
	var dir_access := DirAccess.open(_test_dir)
	if dir_access == null:
		return
	dir_access.list_dir_begin()
	var entry := dir_access.get_next()
	while entry != "":
		if not dir_access.current_is_dir():
			dir_access.remove(entry)
		entry = dir_access.get_next()
	dir_access.list_dir_end()
	DirAccess.remove_absolute(_test_dir)


func _corrupt_file(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("{ isso não é json válido")
	f.flush()
	f.close()


## Compara dois Variants por VALOR, tolerando int/float (JSON não distingue os dois — todo
## número inteiro salvo em profile.json volta como float ao ler de volta; Dictionary/Array `==`
## no Godot exige tipo idêntico por elemento, o que faria um round-trip "correto" (mesmo valor)
## falhar por um detalhe de representação que não é o que "idêntico" precisa significar aqui).
func _values_equal(a: Variant, b: Variant) -> bool:
	if typeof(a) == TYPE_DICTIONARY and typeof(b) == TYPE_DICTIONARY:
		var ad: Dictionary = a
		var bd: Dictionary = b
		if ad.size() != bd.size():
			return false
		for k in ad.keys():
			if not bd.has(k) or not _values_equal(ad[k], bd[k]):
				return false
		return true
	if typeof(a) == TYPE_ARRAY and typeof(b) == TYPE_ARRAY:
		var aa: Array = a
		var ba: Array = b
		if aa.size() != ba.size():
			return false
		for i in aa.size():
			if not _values_equal(aa[i], ba[i]):
				return false
		return true
	var a_numeric := typeof(a) == TYPE_INT or typeof(a) == TYPE_FLOAT
	var b_numeric := typeof(b) == TYPE_INT or typeof(b) == TYPE_FLOAT
	if a_numeric and b_numeric:
		return float(a) == float(b)
	return a == b


func test_round_trip_all_blocks() -> void:
	var service := FileSaveService.new(_test_dir)
	service.data.player = {"nickname": "Rico"}
	service.data.progress = {"xp": 100}
	service.data.stats = {"matches": 5}
	service.data.records = {"best_seal": 42}
	service.data.wallet = {"sparks": 10}
	service.data.inventory = {"skins": ["default"]}
	service.data.achievements = {"first_win": true}
	service.data.challenges = {"daily": "active"}
	service.save_profile(true)

	var reloaded := FileSaveService.new(_test_dir)
	var result := reloaded.load_profile()

	assert_eq(result, SaveService.SaveResult.OK, "carga de save recém-salvo deveria ser OK")
	assert_true(_values_equal(reloaded.data.to_dict(), service.data.to_dict()), "round-trip deveria produzir os mesmos valores em todos os blocos")


func test_interrupted_atomic_write_preserves_previous() -> void:
	var service := FileSaveService.new(_test_dir)
	service.data.player = {"nickname": "Original"}
	service.save_profile(true)

	# Simula uma escrita interrompida: cria profile.json.tmp preenchido, mas o rename() final
	# nunca acontece (o que _write_atomic faria por último).
	var tmp_file := FileAccess.open(_test_dir.path_join("profile.json.tmp"), FileAccess.WRITE)
	tmp_file.store_string(JSON.stringify({"meta": {"schema_version": 1}, "player": {"nickname": "Interrompido"}}, "  "))
	tmp_file.flush()
	tmp_file.close()

	var reloaded := FileSaveService.new(_test_dir)
	var result := reloaded.load_profile()

	assert_eq(result, SaveService.SaveResult.OK, "profile.json original não deveria ter sido afetado pelo .tmp órfão")
	assert_eq(reloaded.data.player.get("nickname"), "Original", "escrita interrompida nunca deveria substituir o save anterior")


func test_corrupted_json_falls_back_to_backup() -> void:
	var service := FileSaveService.new(_test_dir)
	service.data.player = {"nickname": "Backup"}
	service.save_profile(true)
	service.data.player = {"nickname": "Novo"}
	service.save_profile(true)

	_corrupt_file(_test_dir.path_join("profile.json"))

	var reloaded := FileSaveService.new(_test_dir)
	var result := reloaded.load_profile()

	assert_eq(result, SaveService.SaveResult.RESTORED_FROM_BACKUP)
	assert_eq(reloaded.data.player.get("nickname"), "Backup", "deveria restaurar do profile.json.bak válido")


func test_corrupted_backup_recreates_without_deleting() -> void:
	var service := FileSaveService.new(_test_dir)
	service.save_profile(true)

	var main_path := _test_dir.path_join("profile.json")
	var bak_path := _test_dir.path_join("profile.json.bak")
	_corrupt_file(main_path)
	_corrupt_file(bak_path)

	var reloaded := FileSaveService.new(_test_dir)
	var result := reloaded.load_profile()

	assert_eq(result, SaveService.SaveResult.RECREATED)
	# load_profile() em RECREATED grava um profile.json novo (perfil vazio) na mesma posição —
	# profile.json volta a existir por design, mas com conteúdo fresco, não o corrompido. O que
	# nunca pode acontecer é o arquivo SUSPEITO ter sido apagado: ele tem que sobreviver
	# renomeado como .corrupt-<timestamp> (checado abaixo). profile.json.bak não deveria
	# reaparecer nesta escrita, pois o profile.json novo não tinha um "principal" válido anterior
	# para copiar no momento da escrita (foi renomeado antes).
	assert_true(FileAccess.file_exists(main_path), "profile.json deveria ter sido recriado com um perfil novo")
	assert_false(FileAccess.file_exists(bak_path), "profile.json.bak não deveria ter sido recriado nesta escrita (não havia principal válido para copiar)")

	var found_main_corrupt := false
	var found_bak_corrupt := false
	var dir_access := DirAccess.open(_test_dir)
	dir_access.list_dir_begin()
	var entry := dir_access.get_next()
	while entry != "":
		if entry.begins_with("profile.json.bak.corrupt-"):
			found_bak_corrupt = true
		elif entry.begins_with("profile.json.corrupt-"):
			found_main_corrupt = true
		entry = dir_access.get_next()
	dir_access.list_dir_end()

	assert_true(found_main_corrupt, "profile.json corrompido deveria ter sido renomeado, nunca apagado")
	assert_true(found_bak_corrupt, "profile.json.bak corrompido deveria ter sido renomeado, nunca apagado")


func test_fake_migration_v1_to_v2() -> void:
	DirAccess.make_dir_recursive_absolute(_test_dir)
	var fixture_text := FileAccess.get_file_as_string("res://tests/fixtures/save_migration_v1_fake.json")
	var f := FileAccess.open(_test_dir.path_join("profile.json"), FileAccess.WRITE)
	f.store_string(fixture_text)
	f.flush()
	f.close()

	var service := FileSaveService.new(_test_dir)
	service.register_migration(FakeMigrationV1ToV2.new())
	var result := service.load_profile()

	assert_eq(result, SaveService.SaveResult.OK)
	assert_eq(service.data.meta.get("schema_version"), 2, "migração fake deveria avançar schema_version de 1 para 2")
	assert_eq(service.data.player.get("nickname"), "Legacy", "migração fake deveria renomear old_nickname_field para nickname")


func test_unknown_field_preserved() -> void:
	var service := FileSaveService.new(_test_dir)
	service.data.player["custom_test_field"] = "kept"
	service.save_profile(true)

	var reloaded := FileSaveService.new(_test_dir)
	reloaded.load_profile()

	assert_eq(reloaded.data.player.get("custom_test_field"), "kept", "chave desconhecida dentro de um bloco deveria sobreviver ao ciclo save/load")


func test_settings_survive_profile_corruption() -> void:
	var service := FileSaveService.new(_test_dir)
	service.data.settings = {"locale": "pt-BR", "haptics": false}
	service.save_settings()

	_corrupt_file(_test_dir.path_join("profile.json"))
	_corrupt_file(_test_dir.path_join("profile.json.bak"))

	var profile_result := service.load_profile()
	var settings_result := service.load_settings()

	assert_eq(profile_result, SaveService.SaveResult.RECREATED, "profile.json e o backup corrompidos deveriam recriar o perfil")
	assert_eq(settings_result, SaveService.SaveResult.OK, "settings.json não deveria ter sido tocado pela corrupção do perfil")
	assert_eq(service.data.settings.get("locale"), "pt-BR", "settings deveriam sobreviver intactas à corrupção total do perfil")
