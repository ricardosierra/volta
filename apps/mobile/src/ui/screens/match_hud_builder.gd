class_name MatchHudBuilder
extends RefCounted

## Fábrica dos nós de HUD de MatchScreen. Extraída por tamanho de função (Regra 8 do
## CLAUDE.md — _build_hud tinha 87 linhas, _build_result_overlay tinha 54). Só cria e
## devolve nós; MatchScreen decide o que guardar e a que sinal conectar.

static func build_hud(parent: Control, header_top: float) -> Dictionary:
	var elements: Dictionary = {}
	_build_top_bar(parent, header_top, elements)
	_build_status_row(parent, header_top, elements)
	_build_countdown_label(parent, elements)
	_build_hint_label(parent, elements)
	_build_actions(parent, elements)
	return elements


static func build_result_overlay(parent: Control, elements: Dictionary) -> void:
	_build_result_shell(parent, elements)
	_build_result_content(elements)


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

	var territory_label := make_hud_label("ÁREA 00%", HORIZONTAL_ALIGNMENT_LEFT, 38)
	territory_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(territory_label)

	var kills_label := make_hud_label("KOs 0", HORIZONTAL_ALIGNMENT_CENTER, 38)
	kills_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(kills_label)

	var opponents_label := make_hud_label("RIVAIS 0", HORIZONTAL_ALIGNMENT_CENTER, 38)
	opponents_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(opponents_label)

	var time_label := make_hud_label("00:00", HORIZONTAL_ALIGNMENT_RIGHT, 38)
	time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(time_label)

	elements["top_bar"] = top_bar
	elements["territory_label"] = territory_label
	elements["kills_label"] = kills_label
	elements["opponents_label"] = opponents_label
	elements["time_label"] = time_label


static func _build_status_row(parent: Control, header_top: float, elements: Dictionary) -> void:
	var status_label := make_hud_label("PARTIDA  •  CORTE OS RASTROS", HORIZONTAL_ALIGNMENT_CENTER, 36)
	status_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	status_label.offset_left = MatchScreen.FIELD_MARGIN
	status_label.offset_top = header_top + 130.0
	status_label.offset_right = -MatchScreen.FIELD_MARGIN
	status_label.offset_bottom = header_top + 176.0
	parent.add_child(status_label)

	var territory_bar := ProgressBar.new()
	territory_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	territory_bar.offset_left = MatchScreen.FIELD_MARGIN
	territory_bar.offset_top = header_top + 186.0
	territory_bar.offset_right = -MatchScreen.FIELD_MARGIN
	territory_bar.offset_bottom = header_top + 216.0
	territory_bar.max_value = 100.0
	territory_bar.show_percentage = false
	territory_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	territory_bar.add_theme_stylebox_override("background", style_box(Color("102235"), Color("1d3d56"), 1, 12))
	territory_bar.add_theme_stylebox_override("fill", style_box(Color("2dd4bf"), Color("6fffe9"), 1, 12))
	parent.add_child(territory_bar)

	elements["status_label"] = status_label
	elements["territory_bar"] = territory_bar


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

	var exit_button := make_button("VOLTAR AO MENU", Vector2(440.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 40)
	actions.add_child(exit_button)

	elements["actions"] = actions
	elements["exit_button"] = exit_button


static func _build_result_shell(parent: Control, elements: Dictionary) -> void:
	var result_overlay := Control.new()
	result_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(result_overlay)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.02, 0.04, 0.08, 0.88)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	result_overlay.add_child(dimmer)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760.0, 800.0)
	panel.add_theme_stylebox_override("panel", style_box(Color("0c1a2a"), Color("2dd4bf"), 2, 24))
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 28)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("margin_left", 48)
	box.add_theme_constant_override("margin_right", 48)
	box.add_theme_constant_override("margin_top", 48)
	box.add_theme_constant_override("margin_bottom", 48)
	panel.add_child(box)

	result_overlay.hide()

	elements["result_overlay"] = result_overlay
	elements["result_box"] = box


static func _build_result_content(elements: Dictionary) -> void:
	var box: VBoxContainer = elements["result_box"]

	var kicker := make_result_label("RESULTADO DA RODADA", 30, Color("6fffe9"))
	box.add_child(kicker)

	var result_title := make_result_label("VITÓRIA", 80, Color("f8fbff"))
	box.add_child(result_title)

	var result_detail := make_result_label("", 38, Color("b9cce0"))
	result_detail.custom_minimum_size = Vector2(0.0, 250.0)
	box.add_child(result_detail)

	var restart_button := make_button("JOGAR NOVAMENTE", Vector2(0.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 40)
	restart_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(restart_button)

	var menu_button := make_button("VOLTAR AO MENU", Vector2(0.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 38)
	menu_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(menu_button)

	elements["result_title"] = result_title
	elements["result_detail"] = result_detail
	elements["restart_button"] = restart_button
	elements["menu_button"] = menu_button


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


static func make_result_label(text: String, font_size: int, color: Color) -> Label:
	var label := make_hud_label(text, HORIZONTAL_ALIGNMENT_CENTER, font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
