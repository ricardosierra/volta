extends GutTest

## Paused congela tudo (MOVE-001, ACCEPTANCE A02-09, ROADMAP Fase 2 critério de sucesso
## #6). Chama _physics_process diretamente em vez de depender de SceneTree.paused (que é a
## segunda camada de proteção usada no jogo real via PauseScreen — ver Plano 02-06):
## enquanto GameState.Id.PLAYING não voltar, nada deveria avançar.

func _new_playing_director() -> MatchDirector:
	var director: MatchDirector = add_child_autofree(MatchDirector.new())
	var arena_def := load("res://resources/arenas/open_field.tres") as ArenaDefinition
	director.configure(ConfigService.new(), arena_def, InputRouter.new())
	var config := Resource.new()
	config.set_meta("bot_count", 1)
	director.setup_match(config)
	director.game_state.request_transition(GameState.Id.PLAYING)
	return director

func test_paused_freezes_position_tick_and_elapsed_time() -> void:
	var director := _new_playing_director()

	for i in range(30):
		director._physics_process(1.0 / 60.0)

	var frozen_position := director.player_runner.state.position
	var frozen_tick := director.clock.current_tick
	var frozen_time := director.time_elapsed

	director.game_state.request_transition(GameState.Id.PAUSED)

	for i in range(30):
		director._physics_process(1.0 / 60.0)

	assert_eq(director.player_runner.state.position, frozen_position, "posição não deveria avançar durante o Paused")
	assert_eq(director.clock.current_tick, frozen_tick, "o tick da simulação não deveria avançar durante o Paused")
	assert_eq(director.time_elapsed, frozen_time, "o tempo decorrido não deveria avançar durante o Paused")

func test_resuming_from_paused_continues_advancing() -> void:
	var director := _new_playing_director()

	for i in range(10):
		director._physics_process(1.0 / 60.0)

	director.game_state.request_transition(GameState.Id.PAUSED)
	for i in range(10):
		director._physics_process(1.0 / 60.0)
	var paused_tick := director.clock.current_tick

	director.game_state.request_transition(GameState.Id.PLAYING)
	for i in range(10):
		director._physics_process(1.0 / 60.0)

	assert_gt(director.clock.current_tick, paused_tick, "retomar o jogo deveria voltar a avançar o tick")
