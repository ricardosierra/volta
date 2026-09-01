extends GutTest

## Regressão da divisão de on_pushed() em _build_title_block()/_build_play_controls()
## (Regra 8 do CLAUDE.md — on_pushed() tinha 55 linhas).

func test_on_pushed_builds_play_button_and_emits_play_requested() -> void:
	var menu := MainMenuScreen.new()
	watch_signals(menu)
	add_child_autofree(menu)

	menu.on_pushed()

	var play_button: Button = menu.find_child("PlayButton", true, false)
	assert_not_null(play_button, "on_pushed() deveria criar o botão PLAY")

	play_button.pressed.emit()
	assert_signal_emitted(menu, "play_requested")
