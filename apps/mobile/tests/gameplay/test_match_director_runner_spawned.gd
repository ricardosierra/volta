extends GutTest

## Prova a inversão de dependência da Regra 7 (CLAUDE.md §3) e, desde o Plano 02-05, que
## setup_match() cria o Runner do jogador (id 0, sem IA) ANTES dos bots — por isso as
## contagens de runner_spawned/runners.size() são bot_count + 1, não bot_count.

func test_setup_match_emits_runner_spawned_for_player_and_each_bot() -> void:
	var director := MatchDirector.new()
	watch_signals(director)

	var config := Resource.new()
	config.set_meta("bot_count", 2)
	director.setup_match(config)

	assert_eq(get_signal_emit_count(director, "runner_spawned"), 3, "1 jogador + 2 bots")
	assert_eq(director.runners.size(), 3)
	assert_true(director.runners[0] is Runner)
	assert_eq(director.runners[0], director.player_runner, "o primeiro runner criado deveria ser o jogador")

	director.queue_free()


func test_setup_match_with_zero_bots_still_emits_for_the_player() -> void:
	var director := MatchDirector.new()
	watch_signals(director)

	var config := Resource.new()
	config.set_meta("bot_count", 0)
	director.setup_match(config)

	assert_eq(get_signal_emit_count(director, "runner_spawned"), 1, "só o jogador, sem bots")
	assert_not_null(director.player_runner)

	director.queue_free()
