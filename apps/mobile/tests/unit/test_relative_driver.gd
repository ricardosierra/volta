extends GutTest

## RelativeDriver (MOVE-007, docs/gameplay/controls.md — esquema 3, "steering"). Já
## implementado corretamente; este teste prova o contrato com eventos sintéticos.

func _touch(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.position = pos
	e.pressed = pressed
	return e

func _drag(pos: Vector2) -> InputEventScreenDrag:
	var e := InputEventScreenDrag.new()
	e.position = pos
	return e

func test_starts_pointing_up() -> void:
	var driver := RelativeDriver.new()
	assert_almost_eq(driver.poll(0.016).angle_to(Vector2.UP), 0.0, 0.001)

func test_dragging_right_rotates_clockwise() -> void:
	var driver := RelativeDriver.new()
	driver.sensitivity = 0.01
	driver.process_event(_touch(Vector2(300, 300), true))
	driver.process_event(_drag(Vector2(400, 300))) # arrastou 100px para a direita

	var direction := driver.poll(0.016)
	assert_gt(direction.x, 0.0, "arrastar para a direita deveria girar no sentido horário, ganhando componente x positiva")

func test_sensitivity_scales_the_rotation() -> void:
	var low_sensitivity := RelativeDriver.new()
	low_sensitivity.sensitivity = 0.002
	low_sensitivity.process_event(_touch(Vector2(300, 300), true))
	low_sensitivity.process_event(_drag(Vector2(400, 300)))

	var high_sensitivity := RelativeDriver.new()
	high_sensitivity.sensitivity = 0.01
	high_sensitivity.process_event(_touch(Vector2(300, 300), true))
	high_sensitivity.process_event(_drag(Vector2(400, 300)))

	assert_gt(
		absf(high_sensitivity.poll(0.016).angle_to(Vector2.UP)),
		absf(low_sensitivity.poll(0.016).angle_to(Vector2.UP)),
		"sensibilidade maior deveria girar mais para o mesmo arraste"
	)

func test_releasing_touch_keeps_current_angle() -> void:
	var driver := RelativeDriver.new()
	driver.process_event(_touch(Vector2(300, 300), true))
	driver.process_event(_drag(Vector2(400, 300)))
	var direction_while_touching := driver.poll(0.016)

	driver.process_event(_touch(Vector2(400, 300), false))
	driver.process_event(_drag(Vector2(500, 300))) # arraste depois de soltar não deveria contar

	assert_eq(driver.poll(0.016), direction_while_touching)
