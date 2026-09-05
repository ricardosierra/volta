extends GutTest

## SwipeDriver (MOVE-005, docs/gameplay/controls.md — zona morta em mm físicos). Prova
## conversão mm->px pura (sem depender de DisplayServer real, headless não tem tela),
## direção contínua durante o arraste, e manutenção da direção ao soltar.

func _touch(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.position = pos
	e.pressed = pressed
	return e

func _drag(pos: Vector2) -> InputEventScreenDrag:
	var e := InputEventScreenDrag.new()
	e.position = pos
	return e

func test_mm_to_px_scales_with_dpi() -> void:
	var px_low_density := SwipeDriver.mm_to_px(3.0, 160.0)
	var px_high_density := SwipeDriver.mm_to_px(3.0, 480.0)
	assert_almost_eq(px_low_density, 18.897, 0.01)
	assert_almost_eq(px_high_density, 56.69, 0.01)
	assert_true(px_high_density > px_low_density, "mesma distância física deveria virar mais pixels numa tela mais densa")

func test_direction_updates_continuously_while_dragging() -> void:
	var driver := SwipeDriver.new()
	driver.deadzone_px = 20.0
	driver.process_event(_touch(Vector2(100, 100), true))
	driver.process_event(_drag(Vector2(150, 100)))
	assert_almost_eq(driver.poll(0.016).x, 1.0, 0.01)

	driver.process_event(_drag(Vector2(130, 160))) # continua o mesmo arraste; start_pos ja foi reancorado pelo poll() anterior
	assert_almost_eq(driver.poll(0.016).y, 1.0, 0.01)

func test_direction_is_kept_after_release() -> void:
	var driver := SwipeDriver.new()
	driver.deadzone_px = 20.0
	driver.process_event(_touch(Vector2(100, 100), true))
	driver.process_event(_drag(Vector2(150, 100)))
	var direction_while_touching := driver.poll(0.016)

	driver.process_event(_touch(Vector2(150, 100), false))

	assert_eq(driver.poll(0.016), direction_while_touching, "soltar o dedo não deveria zerar a direção — o Runner mantém o rumo")

func test_movement_below_deadzone_does_not_change_direction() -> void:
	var driver := SwipeDriver.new()
	driver.deadzone_px = 50.0
	driver.current_dir = Vector2.UP
	driver.process_event(_touch(Vector2(100, 100), true))
	driver.process_event(_drag(Vector2(110, 100))) # 10px < deadzone de 50px
	assert_eq(driver.poll(0.016), Vector2.UP, "arraste menor que a zona morta não deveria mudar a direção")
