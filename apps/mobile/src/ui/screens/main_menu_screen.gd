class_name MainMenuScreen
extends Screen

signal play_requested
signal settings_requested

func on_pushed(args: Dictionary = {}) -> void:
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(vbox)
	
	var title = Label.new()
	title.text = "VOLTA"
	title.add_theme_font_size_override("font_size", 72)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var play_btn = Button.new()
	play_btn.text = "PLAY"
	play_btn.custom_minimum_size = Vector2(200, 80)
	play_btn.pressed.connect(_on_play_pressed)
	vbox.add_child(play_btn)

func _on_play_pressed() -> void:
	play_requested.emit()
