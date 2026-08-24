extends GutTest

## Testes de Build — o único ponto de verdade sobre debug vs release.
## Ainda não roda via test-client.sh (GUT só é instalado no Plano 01-03); a sintaxe é
## validada por ./tools/ci/check-project.sh nesta tarefa. Execução real do GUT começa
## a partir do Plano 01-03.


func test_version_matches_project_settings() -> void:
	assert_eq(Build.version(), "0.1.0")


func test_commit_defaults_to_dev() -> void:
	assert_eq(Build.commit(), "dev")


func test_is_debug_true_when_os_debug_and_flags_enabled() -> void:
	assert_true(Build._compute_is_debug(true, true))


func test_is_debug_false_when_os_not_debug() -> void:
	assert_false(Build._compute_is_debug(false, true))


func test_is_debug_false_when_flags_disabled() -> void:
	assert_false(Build._compute_is_debug(true, false))


func test_is_debug_false_when_both_false() -> void:
	assert_false(Build._compute_is_debug(false, false))
