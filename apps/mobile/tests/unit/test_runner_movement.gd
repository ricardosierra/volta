extends GutTest

## Runner + Movement (docs/design/balance.md §2, ADR-0006). Prova que velocidade/giro vêm
## de RunnerBalance e que inverter 180° leva exatamente 180/turn_rate segundos — critério
## de sucesso #2 do ROADMAP da Fase 2.

const PHYSICS_DT: float = 1.0 / 60.0

func test_speed_and_turn_rate_come_from_balance() -> void:
	var balance := RunnerBalance.new()
	var runner := Runner.new(1, Vector2.ZERO, Vector2.UP, balance)
	assert_eq(runner.stats.get_speed(), balance.base_speed)
	assert_eq(runner.stats.get_turn_rate(), balance.turn_rate)

func test_constant_direction_moves_in_straight_line_at_base_speed() -> void:
	var balance := RunnerBalance.new()
	var runner := Runner.new(1, Vector2.ZERO, Vector2.RIGHT, balance)
	runner.set_desired_direction(Vector2.RIGHT)
	runner.tick(PHYSICS_DT)
	assert_almost_eq(runner.state.position.x, balance.base_speed * PHYSICS_DT, 0.001)
	assert_almost_eq(runner.state.position.y, 0.0, 0.001)

func test_180_degree_turn_takes_exactly_180_over_turn_rate_seconds() -> void:
	var balance := RunnerBalance.new()
	var runner := Runner.new(1, Vector2.ZERO, Vector2.UP, balance)
	runner.set_desired_direction(Vector2.DOWN)

	var expected_seconds: float = 180.0 / balance.turn_rate
	var ticks_needed: int = int(round(expected_seconds / PHYSICS_DT))

	for i in range(ticks_needed - 1):
		runner.tick(PHYSICS_DT)
	# UP->DOWN e uma virada de exatamente 180 graus: rotate_toward() resolve a ambiguidade de
	# sinal indo sempre no sentido negativo (Math::rotate_toward, wrapf(PI, -PI, PI) == -PI),
	# entao o angulo restante um tick antes de completar e negativo (-9 graus), nao positivo.
	# O que a asserção prova e a MAGNITUDE do angulo restante, nao o sinal.
	assert_gt(absf(runner.state.direction.angle_to(Vector2.DOWN)), deg_to_rad(1.0), "um tick antes do previsto a virada de 180° ainda não deveria estar completa")

	runner.tick(PHYSICS_DT)
	assert_almost_eq(runner.state.direction.angle_to(Vector2.DOWN), 0.0, 0.001, "após ticks_needed ticks a virada de 180° deveria estar completa")

func test_eliminated_runner_does_not_move() -> void:
	var runner := Runner.new(1, Vector2.ZERO, Vector2.UP, RunnerBalance.new())
	runner.state.fsm_state = RunnerState.State.ELIMINATED
	var start_pos := runner.state.position
	runner.tick(PHYSICS_DT)
	assert_eq(runner.state.position, start_pos)
	assert_eq(runner.state.velocity, Vector2.ZERO)
