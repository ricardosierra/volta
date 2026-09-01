extends GutTest

## Prova a inversão de dependência da Regra 7 (CLAUDE.md §3 / docs/architecture/overview.md
## §1): MatchDirector não conhece mais presentation/ — emite runner_spawned para cada
## Runner criado, em vez de instanciar RunnerView via load() de string.

func test_setup_match_emits_runner_spawned_for_each_bot() -> void:
	var director := MatchDirector.new()
	watch_signals(director)

	var config := Resource.new()
	config.set_meta("bot_count", 2)
	director.setup_match(config)

	assert_eq(get_signal_emit_count(director, "runner_spawned"), 2)
	assert_eq(director.runners.size(), 2)
	assert_true(director.runners[0] is Runner)

	director.queue_free()


func test_setup_match_with_zero_bots_emits_nothing() -> void:
	var director := MatchDirector.new()
	watch_signals(director)

	var config := Resource.new()
	config.set_meta("bot_count", 0)
	director.setup_match(config)

	assert_eq(get_signal_emit_count(director, "runner_spawned"), 0)

	director.queue_free()
