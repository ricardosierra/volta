extends GutTest

## FSM do jogo através do MatchDirector real (MOVE-001/002, ACCEPTANCE A02-08, ROADMAP
## Fase 2 critério de sucesso #6). A cobertura da StateMachine isolada já está em
## test_game_state.gd (Plano 02-02) — este teste prova o mesmo ciclo através do
## MatchDirector de verdade, do jeito que root.gd o usa.

func _new_director_in_countdown(bot_count: int = 0) -> MatchDirector:
	var director: MatchDirector = add_child_autofree(MatchDirector.new())
	var config := Resource.new()
	config.set_meta("bot_count", bot_count)
	director.setup_match(config)
	return director

func test_setup_match_advances_from_boot_to_countdown() -> void:
	var director := _new_director_in_countdown()
	assert_eq(director.game_state.current_state(), GameState.Id.COUNTDOWN)

func test_full_cycle_reaches_results_and_can_restart() -> void:
	var director := _new_director_in_countdown()

	director.game_state.request_transition(GameState.Id.PLAYING)
	assert_eq(director.game_state.current_state(), GameState.Id.PLAYING)

	director.game_state.request_transition(GameState.Id.PAUSED)
	assert_eq(director.game_state.current_state(), GameState.Id.PAUSED)

	director.game_state.request_transition(GameState.Id.PLAYING)
	assert_eq(director.game_state.current_state(), GameState.Id.PLAYING)

	director.game_state.request_transition(GameState.Id.RESULTS)
	assert_eq(director.game_state.current_state(), GameState.Id.RESULTS)

	director.game_state.request_transition(GameState.Id.LOADING)
	assert_eq(director.game_state.current_state(), GameState.Id.LOADING, "Results -> Loading (jogar de novo)")
