extends GutTest

## PauseScreen + ResultsScreen (MOVE-001). As duas existiam como stubs vazios da Fase 7
## (sinais declarados mas nunca emitidos, sem nenhum botão real). Prova o mínimo que a
## Fase 2 exige: pausar de verdade (SceneTree.paused) e emitir os sinais que MatchScreen
## vai escutar (Task 3 deste plano).

func _find_button(node: Node, text: String) -> Button:
	for child in node.get_children():
		if child is Button and (child as Button).text == text:
			return child
		var found := _find_button(child, text)
		if found:
			return found
	return null

func test_pause_screen_pauses_tree_on_pushed_and_unpauses_on_popped() -> void:
	var pause: PauseScreen = add_child_autofree(PauseScreen.new())
	pause.on_pushed()
	assert_true(get_tree().paused)

	pause.on_popped()
	assert_false(get_tree().paused)

func test_pause_screen_resume_button_emits_resume_requested() -> void:
	var pause: PauseScreen = add_child_autofree(PauseScreen.new())
	pause.on_pushed()
	watch_signals(pause)

	_find_button(pause, "CONTINUAR").pressed.emit()

	assert_signal_emitted(pause, "resume_requested")
	pause.on_popped()

func test_pause_screen_quit_button_emits_quit_requested() -> void:
	var pause: PauseScreen = add_child_autofree(PauseScreen.new())
	pause.on_pushed()
	watch_signals(pause)

	_find_button(pause, "DESISTIR").pressed.emit()

	assert_signal_emitted(pause, "quit_requested")
	pause.on_popped()

func test_pause_screen_handle_back_button_emits_resume_requested() -> void:
	var pause: PauseScreen = add_child_autofree(PauseScreen.new())
	pause.on_pushed()
	watch_signals(pause)

	assert_true(pause.handle_back_button())
	assert_signal_emitted(pause, "resume_requested")
	pause.on_popped()

func test_results_screen_is_a_screen_and_emits_both_signals() -> void:
	var results: ResultsScreen = add_child_autofree(ResultsScreen.new())
	assert_true(results is Screen, "ResultsScreen precisa estender Screen para ser empilhável")

	results.on_pushed()
	watch_signals(results)

	_find_button(results, "JOGAR NOVAMENTE").pressed.emit()
	assert_signal_emitted(results, "play_again_requested")

	_find_button(results, "VOLTAR AO MENU").pressed.emit()
	assert_signal_emitted(results, "menu_requested")
