class_name SwipeDriver
extends InputDriver

var is_touching: bool = false
var start_pos: Vector2 = Vector2.ZERO
var current_pos: Vector2 = Vector2.ZERO
var current_dir: Vector2 = Vector2.UP

# Physical deadzone: approx 3mm. Converted to pixels based on DPI later.
var deadzone_mm: float = 3.0
var deadzone_px: float = 20.0

func _init() -> void:
	var dpi = DisplayServer.screen_get_dpi()
	if dpi > 0:
		# 1 inch = 25.4 mm
		deadzone_px = (deadzone_mm / 25.4) * dpi
	
	# Connect to global input events or process them manually
	# For architectural separation, the router or an autoload usually feeds events to the driver.
	# Here we'll rely on the Router forwarding events.

func process_event(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			# Ignore touches on UI (Control nodes handle input and stop propagation usually, 
			# but we should check if needed or rely on Godot's unhandled input)
			is_touching = true
			start_pos = event.position
			current_pos = event.position
		else:
			is_touching = false
			
	elif event is InputEventScreenDrag and is_touching:
		current_pos = event.position

func poll(_delta: float) -> Vector2:
	if is_touching:
		var diff = current_pos - start_pos
		if diff.length() > deadzone_px:
			current_dir = diff.normalized()
			# Reset start pos so it acts like a continuous joystick
			start_pos = current_pos - (current_dir * deadzone_px)
			
	return current_dir
