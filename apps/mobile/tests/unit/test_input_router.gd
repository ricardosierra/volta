extends GutTest

## InputRouter (MOVE-005/MOVE-006, docs/gameplay/controls.md, ADR-0014). Prova que o
## buffer fica no caminho de poll_direction() e que trocar de driver não vaza estado.

func _touch(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.position = pos
	e.pressed = pressed
	return e

func _drag(pos: Vector2) -> InputEventScreenDrag:
	var e := InputEventScreenDrag.new()
	e.position = pos
	return e

func test_router_is_usable_immediately_after_new_without_ready() -> void:
	var router := InputRouter.new()
	assert_not_null(router.driver)
	assert_not_null(router.buffer)
	assert_eq(router.poll_direction(0.016), Vector2.UP, "sem nenhum toque, o SwipeDriver default aponta para cima")

func test_unhandled_input_outside_tree_does_not_crash() -> void:
	var router := InputRouter.new()
	router._unhandled_input(_touch(Vector2(100, 100), true))
	router._unhandled_input(_drag(Vector2(200, 100)))
	assert_gt(router.poll_direction(0.016).x, 0.0, "arrastar para a direita deveria produzir direção com x positivo")

func test_two_distinct_commands_between_polls_are_consumed_in_order() -> void:
	var router := InputRouter.new()
	router.buffer.push_command(Vector2.RIGHT)
	router.buffer.push_command(Vector2.DOWN)

	var first := router.poll_direction(0.01)
	var second := router.poll_direction(0.01)

	assert_eq(first, Vector2.RIGHT)
	assert_eq(second, Vector2.DOWN)

func test_set_driver_resets_the_buffer() -> void:
	var router := InputRouter.new()
	router.buffer.push_command(Vector2.LEFT)
	assert_true(router.buffer.has_commands())

	router.set_driver(SwipeDriver.new())

	assert_false(router.buffer.has_commands(), "trocar de esquema não deveria carregar comando do esquema anterior")
