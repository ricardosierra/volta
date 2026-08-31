class_name SplashScreen
extends Screen

signal finished


func on_pushed(_args: Dictionary = {}) -> void:
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

	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(640.0, 0.0)
	box.add_theme_constant_override("separation", 24)
	center.add_child(box)

	var title := Label.new()
	title.text = "VOLTA"
	title.add_theme_font_size_override("font_size", 96)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.modulate.a = 0.0
	box.add_child(title)

	var loading := Label.new()
	loading.text = "PREPARANDO O CAMPO"
	loading.add_theme_font_size_override("font_size", 22)
	loading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading.modulate.a = 0.0
	box.add_child(loading)

	var tween := create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 0.30)
	tween.parallel().tween_property(loading, "modulate:a", 1.0, 0.30)
	tween.tween_interval(1.20)
	tween.tween_callback(_on_splash_done)


func _on_splash_done() -> void:
	finished.emit()
