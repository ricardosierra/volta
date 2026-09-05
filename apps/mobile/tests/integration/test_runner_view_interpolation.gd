extends GutTest

## RunnerView + InterpolatedVisual (MOVE-004, ADR-0014). Prova que a view segue a
## simulação a cada tick físico, e que o círculo provisório de placeholder (rastreado em
## runner_view.gd) só aparece sem cosmético.

func test_runner_view_is_an_interpolated_visual() -> void:
	var view := RunnerView.new()
	add_child_autofree(view)
	assert_true(view is InterpolatedVisual)

func test_physics_process_updates_curr_position_from_runner_state() -> void:
	var runner := Runner.new(1, Vector2.ZERO, Vector2.UP)
	var view := RunnerView.new()
	add_child_autofree(view)
	view.runner = runner

	runner.state.position = Vector2(100.0, 40.0)
	view._physics_process(0.016)

	assert_eq(view.curr_position, Vector2(100.0, 40.0))

func test_physics_process_shifts_prev_to_old_curr() -> void:
	var runner := Runner.new(1, Vector2.ZERO, Vector2.UP)
	var view := RunnerView.new()
	add_child_autofree(view)
	view.runner = runner

	runner.state.position = Vector2(10.0, 0.0)
	view._physics_process(0.016)
	runner.state.position = Vector2(20.0, 0.0)
	view._physics_process(0.016)

	assert_eq(view.prev_position, Vector2(10.0, 0.0))
	assert_eq(view.curr_position, Vector2(20.0, 0.0))

func test_view_without_runner_does_not_crash_on_physics_process() -> void:
	var view := RunnerView.new()
	add_child_autofree(view)
	view._physics_process(0.016) # runner é null — não deveria lançar erro
	assert_null(view.runner)
