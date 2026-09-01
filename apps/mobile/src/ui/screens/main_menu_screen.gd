class_name MainMenuScreen
extends Screen

signal play_requested
signal settings_requested

func on_pushed(args: Dictionary = {}) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("07111e")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(640.0, 0.0)
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)

	_build_title_block(vbox)
	_build_play_controls(vbox)

func _build_title_block(vbox: VBoxContainer) -> void:
	var eyebrow := Label.new()
	eyebrow.text = "TERRITORY RUNNER"
	eyebrow.add_theme_font_size_override("font_size", 22)
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(eyebrow)

	var title := Label.new()
	title.text = "VOLTA"
	title.add_theme_font_size_override("font_size", 96)
	title.custom_minimum_size = Vector2(640.0, 140.0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Trace seu arco. Conquiste o campo."
	subtitle.add_theme_font_size_override("font_size", 28)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)

func _build_play_controls(vbox: VBoxContainer) -> void:
	var play_btn := Button.new()
	play_btn.name = "PlayButton"
	play_btn.text = "PLAY"
	play_btn.custom_minimum_size = Vector2(640.0, 164.0)
	play_btn.add_theme_font_size_override("font_size", 64)
	play_btn.pressed.connect(_on_play_pressed)
	vbox.add_child(play_btn)

	var hint := Label.new()
	hint.text = "Toque para começar"
	hint.add_theme_font_size_override("font_size", 24)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)

	play_btn.grab_focus()

func _on_play_pressed() -> void:
	play_requested.emit()
