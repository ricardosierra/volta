extends GutTest

## Testes de Log — nível mínimo por categoria, supressão de sink quando o nível está
## desabilitado, e rotação de arquivo do FileLogSink. Log é o singleton autoload; cada teste
## restaura sinks e níveis padrão em after_each() para não vazar estado para outros arquivos
## de teste que também usam Log (ex.: test_bootstrap.gd).

class TestSink extends LogSink:
	var calls: int = 0

	func write(category: int, level: int, key: String, data: Dictionary) -> void:
		calls += 1


func after_each() -> void:
	Log._set_sinks_for_test([FileLogSink.new()])
	for cat in Log.Category.values():
		Log.set_min_level(cat, Log.Level.INFO)


func test_disabled_level_does_not_call_sink() -> void:
	var spy := TestSink.new()
	Log._set_sinks_for_test([spy])
	Log.set_min_level(Log.Category.GAMEPLAY, Log.Level.ERROR)

	Log.debug(Log.Category.GAMEPLAY, "should_not_log")

	assert_eq(spy.calls, 0, "sink não deveria ser chamado com nível desabilitado")


func test_level_respected_per_category() -> void:
	Log.set_min_level(Log.Category.AI, Log.Level.WARN)

	assert_false(Log.enabled(Log.Category.AI, Log.Level.INFO), "INFO abaixo do mínimo WARN deveria estar desabilitado")
	assert_true(Log.enabled(Log.Category.AI, Log.Level.WARN), "WARN no mínimo configurado deveria estar habilitado")
	assert_true(Log.enabled(Log.Category.SAVE, Log.Level.INFO), "categoria não configurada permanece em INFO")


func test_file_sink_rotates() -> void:
	var dir := DirAccess.open(FileLogSink.LOG_DIR)
	if dir == null:
		DirAccess.make_dir_recursive_absolute(FileLogSink.LOG_DIR)
		dir = DirAccess.open(FileLogSink.LOG_DIR)
	for i in range(FileLogSink.MAX_FILES + 2):
		var stale := "%s%s_%d.log" % [FileLogSink.LOG_DIR, FileLogSink.BASE_NAME, i]
		if FileAccess.file_exists(stale):
			dir.remove(stale)

	var sink := FileLogSink.new()
	var big_data := {"payload": "x".repeat(4096)}
	for i in range(800):
		sink.write(Log.Category.PERFORMANCE, Log.Level.INFO, "stress_entry", big_data)

	var found := 0
	var max_index := -1
	for i in range(FileLogSink.MAX_FILES + 2):
		var p := "%s%s_%d.log" % [FileLogSink.LOG_DIR, FileLogSink.BASE_NAME, i]
		if FileAccess.file_exists(p):
			found += 1
			max_index = maxi(max_index, i)

	assert_true(found > 1, "esperava mais de um arquivo de log após ultrapassar MAX_BYTES")
	assert_true(max_index < FileLogSink.MAX_FILES, "índice de arquivo não deve passar de MAX_FILES - 1")

	for i in range(FileLogSink.MAX_FILES):
		var p := "%s%s_%d.log" % [FileLogSink.LOG_DIR, FileLogSink.BASE_NAME, i]
		if FileAccess.file_exists(p):
			dir.remove(p)
