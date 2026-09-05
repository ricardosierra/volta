extends GutTest

## InputBuffer (MOVE-006, docs/gameplay/controls.md — "nenhum toque é descartado").
## Comportamento já implementado; este teste prova o contrato antes de InputRouter passar
## a depender dele (ver test_input_router.gd no mesmo plano).

func test_two_distinct_commands_are_queued_in_order() -> void:
	var buffer := InputBuffer.new()
	buffer.push_command(Vector2.RIGHT)
	buffer.push_command(Vector2.UP)

	assert_eq(buffer.pop_command(), Vector2.RIGHT)
	assert_eq(buffer.pop_command(), Vector2.UP)

func test_near_identical_command_is_not_queued_again() -> void:
	var buffer := InputBuffer.new()
	buffer.push_command(Vector2.RIGHT)
	buffer.push_command(Vector2(1.0, 0.02).normalized()) # quase idêntico, dot > 0.95

	assert_eq(buffer.pop_command(), Vector2.RIGHT)
	assert_false(buffer.has_commands(), "comando quase idêntico ao último não deveria ter sido enfileirado de novo")

func test_old_command_is_discarded_by_age() -> void:
	var buffer := InputBuffer.new()
	buffer.max_age = 0.5
	buffer.push_command(Vector2.RIGHT)

	buffer.tick(0.6) # passou da idade máxima

	assert_false(buffer.has_commands(), "comando mais velho que max_age deveria ter sido descartado")

func test_command_within_age_survives_tick() -> void:
	var buffer := InputBuffer.new()
	buffer.max_age = 0.5
	buffer.push_command(Vector2.RIGHT)

	buffer.tick(0.3) # ainda dentro da idade máxima

	assert_true(buffer.has_commands())
	assert_eq(buffer.peek_command(), Vector2.RIGHT)

func test_empty_buffer_returns_zero_vector_without_error() -> void:
	var buffer := InputBuffer.new()
	assert_false(buffer.has_commands())
	assert_eq(buffer.pop_command(), Vector2.ZERO)
	assert_eq(buffer.peek_command(), Vector2.ZERO)

func test_ignores_near_zero_direction() -> void:
	var buffer := InputBuffer.new()
	buffer.push_command(Vector2(0.01, 0.01))
	assert_false(buffer.has_commands(), "direção quase nula não deveria virar comando")
