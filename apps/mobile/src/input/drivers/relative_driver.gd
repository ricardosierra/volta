class_name RelativeDriver
extends InputDriver

var is_touching: bool = false
var last_pos: Vector2 = Vector2.ZERO
var current_angle: float = 0.0 # Base angle, typically -PI/2 (UP)
var sensitivity: float = 0.01

func _init() -> void:
	current_angle = -PI / 2.0

func process_event(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			is_touching = true
			last_pos = event.position
		else:
			is_touching = false
			
	elif event is InputEventScreenDrag and is_touching:
		var diff_x: float = event.position.x - last_pos.x
		current_angle += diff_x * sensitivity
		last_pos = event.position

func poll(_delta: float) -> Vector2:
	return Vector2.RIGHT.rotated(current_angle)
