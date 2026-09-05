extends GutTest

## JoystickDriver (MOVE-007, docs/gameplay/controls.md — esquema 2). Já implementado
## corretamente; este teste prova o contrato com eventos sintéticos, sem tocar no código.

func _touch(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.position = pos
	e.pressed = pressed
	return e

func _drag(pos: Vector2) -> InputEventScreenDrag:
	var e := InputEventScreenDrag.new()
	e.position = pos
	return e

func test_joystick_appears_at_touch_point_and_follows_drag() -> void:
	var driver := JoystickDriver.new()
	driver.process_event(_touch(Vector2(300, 300), true))
	driver.process_event(_drag(Vector2(350, 300)))
	assert_almost_eq(driver.poll(0.016).x, 1.0, 0.01)

func test_direction_below_deadzone_keeps_previous_direction() -> void:
	var driver := JoystickDriver.new()
	driver.current_dir = Vector2.UP
	driver.deadzone = 20.0
	driver.process_event(_touch(Vector2(300, 300), true))
	driver.process_event(_drag(Vector2(305, 300))) # 5px < deadzone de 20px
	assert_eq(driver.poll(0.016), Vector2.UP)

func test_drag_beyond_radius_is_clamped_but_direction_still_follows() -> void:
	var driver := JoystickDriver.new()
	driver.radius = 100.0
	driver.process_event(_touch(Vector2(300, 300), true))
	driver.process_event(_drag(Vector2(300, 600))) # bem além do raio, reto para baixo
	assert_almost_eq(driver.poll(0.016).y, 1.0, 0.01)

func test_releasing_touch_keeps_last_direction() -> void:
	var driver := JoystickDriver.new()
	driver.process_event(_touch(Vector2(300, 300), true))
	driver.process_event(_drag(Vector2(350, 300)))
	var direction_while_touching := driver.poll(0.016)

	driver.process_event(_touch(Vector2(350, 300), false))

	assert_eq(driver.poll(0.016), direction_while_touching)
