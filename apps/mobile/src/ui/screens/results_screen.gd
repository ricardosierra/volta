class_name ResultsScreen
extends Screen

## Tela provisória do estado Results (MOVE-001, "rótulo de texto + botão"). Nesta fase o
## jogo não tem território/combate/placar (Fases 3/4/6) — show_results() com um MatchResult
## real fica para a Fase 6 (MTC-01..04, docs/design/scoring.md); por enquanto on_pushed()
## mostra um resumo genérico e os dois botões de saída.

signal play_again_requested
signal menu_requested

func on_pushed(_args: Dictionary = {}) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func show_results(result: MatchResult) -> void:
	# Display placements, highlight personal best, etc.
	pass

func handle_back_button() -> bool:
	menu_requested.emit()
	return true

func _build_ui() -> void:
	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.02, 0.04, 0.08, 0.88)
	add_child(dimmer)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	center.add_child(box)

	var title := Label.new()
	title.text = "PARTIDA ENCERRADA"
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color("f8fbff"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var detail := Label.new()
	detail.text = "Território, combate e placar chegam nas fases 3, 4 e 6."
	detail.add_theme_font_size_override("font_size", 32)
	detail.add_theme_color_override("font_color", Color("b9cce0"))
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.custom_minimum_size = Vector2(600.0, 0.0)
	box.add_child(detail)

	var play_again_button := MatchHudBuilder.make_button("JOGAR NOVAMENTE", Vector2(440.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 40)
	play_again_button.pressed.connect(func(): play_again_requested.emit())
	box.add_child(play_again_button)

	var menu_button := MatchHudBuilder.make_button("VOLTAR AO MENU", Vector2(440.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 38)
	menu_button.pressed.connect(func(): menu_requested.emit())
	box.add_child(menu_button)
