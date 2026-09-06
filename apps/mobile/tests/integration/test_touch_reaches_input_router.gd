extends GutTest

## Regressao do bug achado no aparelho (GSD 02, Plano 02-07, Task 2): com 124 testes headless
## verdes, o jogo estava SEM CONTROLE no Android. O InputRouter escuta _unhandled_input, mas o
## ScreenStack (Control em full rect com o MOUSE_FILTER_STOP padrao) consumia todo toque antes
## de o evento virar "unhandled". A suite antiga nao pegava porque chamava InputRouter direto,
## em vez de empurrar o evento pelo despacho do viewport.
##
## Estes testes travam o invariante: nenhum conteiner da camada de navegacao pode consumir
## toque. So telas que de fato tem widget (PauseScreen, ResultsScreen, SettingsControls) usam
## MOUSE_FILTER_STOP, e isso e proposital.


func test_screen_stack_never_consumes_touch() -> void:
	var stack := ScreenStack.new()
	add_child_autofree(stack)
	assert_eq(
		stack.mouse_filter,
		Control.MOUSE_FILTER_IGNORE,
		"ScreenStack em full rect com STOP engole o toque e o InputRouter nunca roda"
	)


func test_match_screen_never_consumes_touch() -> void:
	var screen := MatchScreen.new()
	add_child_autofree(screen)
	assert_eq(
		screen.mouse_filter,
		Control.MOUSE_FILTER_IGNORE,
		"MatchScreen cobre a arena inteira; se consumir toque, nao se joga"
	)


func test_touch_event_reaches_unhandled_input_through_the_stack() -> void:
	# Prova ponta a ponta do caminho real: viewport -> stack -> tela -> unhandled_input.
	var stack := ScreenStack.new()
	stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child_autofree(stack)
	stack.push(MatchScreen.new())

	var spy := UnhandledInputSpy.new()
	add_child_autofree(spy)

	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(100.0, 100.0)
	get_tree().root.push_input(touch)

	assert_gt(spy.seen, 0, "o toque nao chegou ao _unhandled_input — a UI consumiu o evento")


class UnhandledInputSpy:
	extends Node

	var seen: int = 0

	func _init() -> void:
		set_process_unhandled_input(true)

	func _unhandled_input(_event: InputEvent) -> void:
		seen += 1
