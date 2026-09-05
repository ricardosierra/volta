class_name PauseScreen
extends Screen

## Tela provisória do estado Paused (MOVE-001, "rótulo de texto + botão" —
## .gsd/phases/02-core-movement/TASKS.md). Empilhada por MatchScreen quando o jogador toca
## PAUSAR. Congela via SceneTree.paused — GameState.PausedState (gameplay/states/paused_state.gd)
## também congela pela FSM; as duas camadas são redundantes de propósito: uma cobre o jogo
## real (aqui), a outra cobre testes headless que chamam _physics_process sem SceneTree.

signal resume_requested
signal restart_requested
signal settings_requested
signal quit_requested

func on_pushed(_args: Dictionary = {}) -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func on_popped() -> void:
	get_tree().paused = false

func handle_back_button() -> bool:
	resume_requested.emit()
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

	var label := Label.new()
	label.text = "PAUSADO"
	label.add_theme_font_size_override("font_size", 64)
	label.add_theme_color_override("font_color", Color("f8fbff"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)

	var resume_button := MatchHudBuilder.make_button("CONTINUAR", Vector2(440.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 40)
	resume_button.pressed.connect(func(): resume_requested.emit())
	box.add_child(resume_button)

	var quit_button := MatchHudBuilder.make_button("DESISTIR", Vector2(440.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 38)
	quit_button.pressed.connect(func(): quit_requested.emit())
	box.add_child(quit_button)
