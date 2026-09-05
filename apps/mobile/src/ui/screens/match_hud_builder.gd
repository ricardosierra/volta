class_name MatchHudBuilder
extends RefCounted

## Fábrica dos nós de HUD de MatchScreen. Extraída por tamanho de função (Regra 8 do
## CLAUDE.md — _build_hud tinha 87 linhas, _build_result_overlay tinha 54). Só cria e
## devolve nós; MatchScreen decide o que guardar e a que sinal conectar.
##
## Desde o Plano 02-06 (Fase 2): território/kills saíram da HUD (Fases 3/4 religam) e o
## overlay de fim de partida virou a tela dedicada ResultsScreen
## (apps/mobile/src/ui/screens/results_screen.gd), empilhada quando o jogo entra em
## GameState.Id.RESULTS — não existe mais build_result_overlay() aqui.

static func build_hud(parent: Control, header_top: float) -> Dictionary:
	var elements: Dictionary = {}
	_build_top_bar(parent, header_top, elements)
	_build_status_row(parent, header_top, elements)
	_build_countdown_label(parent, elements)
	_build_hint_label(parent, elements)
	_build_actions(parent, elements)
	return elements


static func _build_top_bar(parent: Control, header_top: float, elements: Dictionary) -> void:
	var top_bar := HBoxContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_left = MatchScreen.PANEL_MARGIN
	top_bar.offset_top = header_top + 14.0
	top_bar.offset_right = -MatchScreen.PANEL_MARGIN
	top_bar.offset_bottom = header_top + 112.0
	top_bar.add_theme_constant_override("separation", 12)
	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(top_bar)

	var opponents_label := make_hud_label("RIVAIS 0", HORIZONTAL_ALIGNMENT_LEFT, 38)
	opponents_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(opponents_label)

	var time_label := make_hud_label("00:00", HORIZONTAL_ALIGNMENT_RIGHT, 38)
	time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(time_label)

	elements["top_bar"] = top_bar
	elements["opponents_label"] = opponents_label
	elements["time_label"] = time_label


static func _build_status_row(parent: Control, header_top: float, elements: Dictionary) -> void:
	var status_label := make_hud_label("PARTIDA  •  VIRE PARA EXPLORAR A ARENA", HORIZONTAL_ALIGNMENT_CENTER, 36)
	status_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	status_label.offset_left = MatchScreen.FIELD_MARGIN
	status_label.offset_top = header_top + 130.0
	status_label.offset_right = -MatchScreen.FIELD_MARGIN
	status_label.offset_bottom = header_top + 176.0
	parent.add_child(status_label)

	elements["status_label"] = status_label


static func _build_countdown_label(parent: Control, elements: Dictionary) -> void:
	var countdown_label := Label.new()
	countdown_label.set_anchors_preset(Control.PRESET_CENTER)
	countdown_label.offset_left = -180.0
	countdown_label.offset_top = -125.0
	countdown_label.offset_right = 180.0
	countdown_label.offset_bottom = 40.0
	countdown_label.add_theme_font_size_override("font_size", 108)
	countdown_label.add_theme_color_override("font_color", Color("f8fbff"))
	countdown_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
	countdown_label.add_theme_constant_override("shadow_offset_x", 4)
	countdown_label.add_theme_constant_override("shadow_offset_y", 6)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(countdown_label)

	elements["countdown_label"] = countdown_label


static func _build_hint_label(parent: Control, elements: Dictionary) -> void:
	var hint_label := make_hud_label("DESLIZE OU USE AS SETAS PARA VIRAR", HORIZONTAL_ALIGNMENT_CENTER, 34)
	hint_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hint_label.offset_left = MatchScreen.FIELD_MARGIN
	hint_label.offset_top = MatchScreen.FIELD_BOTTOM + 88.0
	hint_label.offset_right = -MatchScreen.FIELD_MARGIN
	hint_label.offset_bottom = MatchScreen.FIELD_BOTTOM + 148.0
	parent.add_child(hint_label)

	elements["hint_label"] = hint_label


static func _build_actions(parent: Control, elements: Dictionary) -> void:
	var actions := CenterContainer.new()
	actions.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	actions.offset_top = -236.0
	actions.offset_bottom = -92.0
	actions.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(actions)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	actions.add_child(row)

	var pause_button := make_button("PAUSAR", Vector2(260.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 36)
	row.add_child(pause_button)

	var settings_button := make_button("CONTROLES", Vector2(280.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 36)
	row.add_child(settings_button)

	var exit_button := make_button("VOLTAR AO MENU", Vector2(360.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 36)
	row.add_child(exit_button)

	elements["actions"] = actions
	elements["pause_button"] = pause_button
	elements["settings_button"] = settings_button
	elements["exit_button"] = exit_button


static func make_hud_label(text: String, alignment: HorizontalAlignment, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("e5f1ff"))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


static func make_button(text: String, minimum_size: Vector2, font_size: int) -> Button:
	var button := Button.new()
	button.text = text
	var touch_size := minimum_size
	touch_size.y = maxf(touch_size.y, MatchScreen.MIN_TOUCH_TARGET_HEIGHT)
	button.custom_minimum_size = touch_size
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("f7fbff"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_stylebox_override("normal", style_box(Color("13283a"), Color("28506a"), 1, 12))
	button.add_theme_stylebox_override("hover", style_box(Color("1a3d4f"), Color("6fffe9"), 2, 12))
	button.add_theme_stylebox_override("pressed", style_box(Color("0d1e2e"), Color("f9c74f"), 2, 12))
	return button


static func style_box(background: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 20.0
	box.content_margin_right = 20.0
	box.content_margin_top = 12.0
	box.content_margin_bottom = 12.0
	return box
