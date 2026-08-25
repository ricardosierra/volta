class_name SafeAreaContainer
extends MarginContainer

func _ready() -> void:
	get_tree().root.size_changed.connect(_on_size_changed)
	_update_margins()

func _on_size_changed() -> void:
	_update_margins()

func _update_margins() -> void:
	var safe_area = DisplayServer.get_display_safe_area()
	var window_size = DisplayServer.window_get_size()
	
	if safe_area.size.x == 0 or safe_area.size.y == 0:
		return
		
	# Calculate margins based on safe area rect vs window size
	var top = safe_area.position.y
	var left = safe_area.position.x
	var right = window_size.x - (safe_area.position.x + safe_area.size.x)
	var bottom = window_size.y - (safe_area.position.y + safe_area.size.y)
	
	add_theme_constant_override("margin_top", max(top, 16))
	add_theme_constant_override("margin_left", max(left, 16))
	add_theme_constant_override("margin_right", max(right, 16))
	add_theme_constant_override("margin_bottom", max(bottom, 16))
