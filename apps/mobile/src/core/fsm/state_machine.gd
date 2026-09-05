class_name StateMachine
extends RefCounted

signal state_changed(from_state: int, to_state: int)

var _states: Dictionary = {}
var _transitions: Dictionary = {}
var _current_state_id: int = -1
var _current_state: State = null

func add_state(id: int, state: State) -> void:
	_states[id] = state

func add_transition(from_id: int, to_id: int) -> void:
	if not _transitions.has(from_id):
		_transitions[from_id] = []
	_transitions[from_id].append(to_id)

func request(to_id: int) -> void:
	if _current_state_id == -1:
		_transition_to(to_id)
		return
	
	if not _is_valid_transition(_current_state_id, to_id):
		var msg := "Invalid state transition requested: %d -> %d" % [_current_state_id, to_id]
		if OS.is_debug_build():
			assert(false, msg)
		else:
			push_error(msg)
		return
	
	_transition_to(to_id)

func tick(delta: float) -> void:
	if _current_state:
		_current_state.update(delta)

func get_current_state() -> int:
	return _current_state_id

func _transition_to(to_id: int) -> void:
	var from_id := _current_state_id
	if _current_state:
		_current_state.exit()
	
	_current_state_id = to_id
	_current_state = _states[to_id]
	_current_state.enter()
	
	state_changed.emit(from_id, to_id)

func _is_valid_transition(from_id: int, to_id: int) -> bool:
	if _transitions.has(from_id):
		return _transitions[from_id].has(to_id)
	return false
