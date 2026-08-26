class_name JoystickDriver
extends InputDriver

var is_touching: bool = false
var center_pos: Vector2 = Vector2.ZERO
var current_pos: Vector2 = Vector2.ZERO

var radius: float = 100.0
var deadzone: float = 20.0
var current_dir: Vector2 = Vector2.UP

func process_event(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			is_touching = true
			center_pos = event.position
			current_pos = event.position
		else:
			is_touching = false
			
	elif event is InputEventScreenDrag and is_touching:
		current_pos = event.position
		
		# Clamp to radius visually if we were drawing it
		var diff = current_pos - center_pos
		if diff.length() > radius:
			current_pos = center_pos + diff.normalized() * radius

func poll(_delta: float) -> Vector2:
	if is_touching:
		var diff = current_pos - center_pos
		if diff.length() > deadzone:
			current_dir = diff.normalized()
			
	return current_dir
