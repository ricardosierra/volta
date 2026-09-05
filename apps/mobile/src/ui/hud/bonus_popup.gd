class_name BonusPopup
extends Label

func _ready() -> void:
	add_theme_font_size_override("font_size", 48)
	add_theme_color_override("font_outline_color", Color(0,0,0))
	add_theme_constant_override("outline_size", 4)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
func play_popup(text_val: String, start_pos: Vector2) -> void:
	text = text_val
	position = start_pos
	modulate.a = 1.0
	show()
	
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y - 100, 0.8)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.8).set_delay(0.4)
	tween.tween_callback(hide)
