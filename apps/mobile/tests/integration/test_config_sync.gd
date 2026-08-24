extends GutTest

## TESTS.md (integração): packages/shared/config e apps/mobile/resources/config idênticos.
## A fonte única fica fora de res://, por isso a leitura é por caminho absoluto do SO.
const FILES: Array[String] = ["runner.tres", "territory.tres", "backwash.tres", "score.tres", "surge.tres", "camera.tres"]


func test_shared_config_matches_imported_copy() -> void:
	var repo_root: String = ProjectSettings.globalize_path("res://").path_join("../..").simplify_path()
	var source_dir: String = repo_root.path_join("packages/shared/config/balance")
	var imported_dir: String = ProjectSettings.globalize_path("res://resources/config/balance")
	for file_name in FILES:
		var source: String = FileAccess.get_file_as_string(source_dir.path_join(file_name))
		var imported: String = FileAccess.get_file_as_string(imported_dir.path_join(file_name))
		assert_false(source.is_empty(), "fonte ausente: %s" % file_name)
		assert_eq(imported, source, "%s divergiu de packages/shared/config — rode tools/dev/sync_config.sh" % file_name)
