extends GutTest

## GameState — FSM do jogo (docs/architecture/state-machines.md §2). Cobre as 11 transições
## da tabela e a rejeição de pelo menos 5 pares inválidos (MOVE-001, ACCEPTANCE A02-08).
## GameState._init(director) só guarda a referência. _ready() monta a fsm e chama
## get_tree() (via PausedState), então precisa estar dentro da árvore de verdade —
## add_child_autofree() entra o nó na árvore de teste do GUT, o que dispara _ready()
## automaticamente e evita o erro de engine "Parameter data.tree is null".

func _fresh_game_state() -> GameState:
	var gs := GameState.new(null)
	add_child_autofree(gs)
	return gs

func test_boot_to_loading_first_run_path_works() -> void:
	var gs := _fresh_game_state()
	assert_eq(gs.current_state(), GameState.Id.BOOT)
	gs.request_transition(GameState.Id.LOADING)
	assert_eq(gs.current_state(), GameState.Id.LOADING, "Boot -> Loading (primeira execução) deveria funcionar")

func test_normal_menu_path_covers_seven_transitions() -> void:
	var gs := _fresh_game_state()
	gs.request_transition(GameState.Id.MENU)
	assert_eq(gs.current_state(), GameState.Id.MENU)
	gs.request_transition(GameState.Id.LOADING)
	assert_eq(gs.current_state(), GameState.Id.LOADING)
	gs.request_transition(GameState.Id.COUNTDOWN)
	assert_eq(gs.current_state(), GameState.Id.COUNTDOWN)
	gs.request_transition(GameState.Id.PLAYING)
	assert_eq(gs.current_state(), GameState.Id.PLAYING)
	gs.request_transition(GameState.Id.PAUSED)
	assert_eq(gs.current_state(), GameState.Id.PAUSED)
	gs.request_transition(GameState.Id.PLAYING)
	assert_eq(gs.current_state(), GameState.Id.PLAYING)
	gs.request_transition(GameState.Id.RESULTS)
	assert_eq(gs.current_state(), GameState.Id.RESULTS)
	gs.request_transition(GameState.Id.MENU)
	assert_eq(gs.current_state(), GameState.Id.MENU)

func test_playing_to_results_to_loading_path_works() -> void:
	var gs := _fresh_game_state()
	gs.request_transition(GameState.Id.LOADING)
	gs.request_transition(GameState.Id.COUNTDOWN)
	gs.request_transition(GameState.Id.PLAYING)
	gs.request_transition(GameState.Id.RESULTS)
	assert_eq(gs.current_state(), GameState.Id.RESULTS, "Playing -> Results direto (fim de partida) deveria funcionar")
	gs.request_transition(GameState.Id.LOADING)
	assert_eq(gs.current_state(), GameState.Id.LOADING, "Results -> Loading (jogar de novo) deveria funcionar")

func test_at_least_five_invalid_transitions_are_rejected() -> void:
	var cases := [
		[GameState.Id.BOOT, GameState.Id.PLAYING],
		[GameState.Id.MENU, GameState.Id.RESULTS],
		[GameState.Id.COUNTDOWN, GameState.Id.MENU],
		[GameState.Id.PLAYING, GameState.Id.LOADING],
		[GameState.Id.RESULTS, GameState.Id.PAUSED],
	]
	for pair in cases:
		var gs := _fresh_game_state()
		_walk_to(gs, pair[0])
		gs.request_transition(pair[1])
		assert_eq(gs.current_state(), pair[0], "transição %s -> %s deveria ter sido rejeitada" % [pair[0], pair[1]])
	# cada uma das transições inválidas acima grita no console (assert em
	# StateMachine.request), mas não trava — consumimos os N erros esperados de uma vez,
	# no final, porque assert_engine_error_count soma o total de erros do tipo já visto
	# na chamada (não só os novos desde a última chamada).
	assert_engine_error_count(cases.size(), "as %d transições inválidas deveriam reclamar no console, não travar" % cases.size())

func _walk_to(gs: GameState, target: GameState.Id) -> void:
	var path_from_boot := {
		GameState.Id.BOOT: [],
		GameState.Id.MENU: [GameState.Id.MENU],
		GameState.Id.LOADING: [GameState.Id.LOADING],
		GameState.Id.COUNTDOWN: [GameState.Id.LOADING, GameState.Id.COUNTDOWN],
		GameState.Id.PLAYING: [GameState.Id.LOADING, GameState.Id.COUNTDOWN, GameState.Id.PLAYING],
		GameState.Id.RESULTS: [GameState.Id.LOADING, GameState.Id.COUNTDOWN, GameState.Id.PLAYING, GameState.Id.RESULTS],
	}
	for step in path_from_boot[target]:
		gs.request_transition(step)
