class_name InputRouter
extends Node

var driver: InputDriver

func _ready() -> void:
	# Default driver
	driver = SwipeDriver.new()
	# Hook into unhandled input so UI consumes its input first
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if driver and driver.has_method("process_event"):
		driver.process_event(event)
	
	# Mark as handled if it was a touch to prevent sim bleeding
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		get_viewport().set_input_as_handled()

func poll_direction(delta: float) -> Vector2:
	if driver:
		return driver.poll(delta)
	return Vector2.ZERO

func set_driver(new_driver: InputDriver) -> void:
	driver = new_driver
