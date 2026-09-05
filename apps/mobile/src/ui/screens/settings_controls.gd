class_name SettingsControls
extends Screen

## Tela de test drive de controles (MOVE-007, docs/gameplay/controls.md — "o test drive é
## obrigatório"). Empilhada por MatchScreen sobre a partida em andamento: a simulação
## continua rodando por baixo, então trocar de esquema aqui já é o test drive ao vivo — não
## precisa de uma mini-arena separada nesta fase (isso é polimento de Fase 7).

signal driver_changed(new_driver: InputDriver)

func on_pushed(_args: Dictionary = {}) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func handle_back_button() -> bool:
	exit_requested.emit()
	return true

func _build_ui() -> void:
	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.02, 0.04, 0.08, 0.88)
	add_child(dimmer)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "ESCOLHA O CONTROLE (test drive ao vivo)"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("f8fbff"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var btn_swipe := Button.new()
	btn_swipe.text = "Swipe"
	btn_swipe.pressed.connect(func(): driver_changed.emit(SwipeDriver.new()))
	vbox.add_child(btn_swipe)

	var btn_joy := Button.new()
	btn_joy.text = "Joystick"
	btn_joy.pressed.connect(func(): driver_changed.emit(JoystickDriver.new()))
	vbox.add_child(btn_joy)

	var btn_rel := Button.new()
	btn_rel.text = "Relative"
	btn_rel.pressed.connect(func(): driver_changed.emit(RelativeDriver.new()))
	vbox.add_child(btn_rel)

	var btn_close := Button.new()
	btn_close.text = "Fechar"
	btn_close.pressed.connect(func(): exit_requested.emit())
	vbox.add_child(btn_close)
