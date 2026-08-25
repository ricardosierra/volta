class_name FinalPushBanner
extends Control

var label: Label

func _ready() -> void:
	label = Label.new()
	label.text = "FINAL PUSH"
	label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	label.hide()
	add_child(label)

func show_banner() -> void:
	label.show()
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 2.0).set_delay(1.0)
	tween.tween_callback(label.hide)
	tween.tween_property(label, "modulate:a", 1.0, 0.0) # Reset
