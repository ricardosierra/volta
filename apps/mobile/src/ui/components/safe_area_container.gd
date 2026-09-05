class_name SafeAreaContainer
extends MarginContainer

func _ready() -> void:
	get_tree().get_root().size_changed.connect(_on_size_changed)
	_apply_safe_area()

func _on_size_changed() -> void:
	_apply_safe_area()

func _apply_safe_area() -> void:
	var safe_area := DisplayServer.get_display_safe_area()
	var window_size := DisplayServer.window_get_size()
	
	if safe_area.size.x > 0 and safe_area.size.y > 0:
		add_theme_constant_override("margin_top", safe_area.position.y)
		add_theme_constant_override("margin_bottom", window_size.y - (safe_area.position.y + safe_area.size.y))
		add_theme_constant_override("margin_left", safe_area.position.x)
		add_theme_constant_override("margin_right", window_size.x - (safe_area.position.x + safe_area.size.x))
