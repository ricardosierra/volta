extends GutTest

## StateMachine genérica (docs/architecture/state-machines.md §3, core/fsm/). Prova
## transição válida com sinal, e rejeição de transição inválida sem travar o processo
## (MOVE-001, TESTS.md test_state_machine.gd).

const STATE_A := 0
const STATE_B := 1
const STATE_C := 2

func _machine_with_a_to_b() -> StateMachine:
	var machine := StateMachine.new()
	machine.add_state(STATE_A, State.new())
	machine.add_state(STATE_B, State.new())
	machine.add_state(STATE_C, State.new())
	machine.add_transition(STATE_A, STATE_B)
	machine.request(STATE_A)
	return machine

func test_valid_transition_changes_state_and_emits_signal() -> void:
	var machine := _machine_with_a_to_b()
	watch_signals(machine)

	machine.request(STATE_B)

	assert_eq(machine.get_current_state(), STATE_B)
	assert_signal_emitted_with_parameters(machine, "state_changed", [STATE_A, STATE_B])

func test_invalid_transition_is_rejected_and_state_unchanged() -> void:
	var machine := _machine_with_a_to_b()
	watch_signals(machine)

	machine.request(STATE_C) # A -> C não foi declarada

	# request() faz assert(false, msg) em debug build (StateMachine.request, linha
	# "Invalid state transition requested") — isso reclama no console mas não trava o
	# processo; consumimos o erro esperado para não confundir com uma falha real.
	assert_engine_error_count(1, "transição inválida deveria reclamar no console, não travar")
	assert_eq(machine.get_current_state(), STATE_A, "estado não deveria mudar numa transição inválida")
	assert_signal_not_emitted(machine, "state_changed")

func test_first_request_from_uninitialized_state_always_succeeds() -> void:
	var machine := StateMachine.new()
	machine.add_state(STATE_A, State.new())

	machine.request(STATE_A)

	assert_eq(machine.get_current_state(), STATE_A)
