class_name SwipeDriver
extends InputDriver

var is_touching: bool = false
var start_pos: Vector2 = Vector2.ZERO
var current_pos: Vector2 = Vector2.ZERO
var current_dir: Vector2 = Vector2.UP

# Zona morta física: aprox. 3mm, convertida para pixels pelo DPI real da tela.
var deadzone_mm: float = 3.0
var deadzone_px: float = 20.0

func _init() -> void:
	var dpi := DisplayServer.screen_get_dpi()
	if dpi > 0:
		deadzone_px = mm_to_px(deadzone_mm, dpi)

static func mm_to_px(mm: float, dpi: float) -> float:
	return (mm / 25.4) * dpi

func process_event(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			is_touching = true
			start_pos = event.position
			current_pos = event.position
		else:
			is_touching = false

	elif event is InputEventScreenDrag and is_touching:
		current_pos = event.position

func poll(_delta: float) -> Vector2:
	if is_touching:
		var diff: Vector2 = current_pos - start_pos
		if diff.length() > deadzone_px:
			current_dir = diff.normalized()
			start_pos = current_pos - (current_dir * deadzone_px)

	return current_dir
