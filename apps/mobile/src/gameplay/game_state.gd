class_name GameState
extends Node

enum Id {
	BOOT,
	MENU,
	LOADING,
	COUNTDOWN,
	PLAYING,
	PAUSED,
	RESULTS
}

var fsm: StateMachine
var director: MatchDirector

func _init(dir: MatchDirector) -> void:
	director = dir

func _ready() -> void:
	fsm = StateMachine.new()
	
	fsm.add_state(Id.BOOT, BootState.new())
	fsm.add_state(Id.MENU, MenuState.new())
	fsm.add_state(Id.LOADING, LoadingState.new())
	fsm.add_state(Id.COUNTDOWN, CountdownState.new(director))
	fsm.add_state(Id.PLAYING, PlayingState.new())
	fsm.add_state(Id.PAUSED, PausedState.new(get_tree()))
	fsm.add_state(Id.RESULTS, ResultsState.new())
	
	fsm.add_transition(Id.BOOT, Id.MENU)
	fsm.add_transition(Id.BOOT, Id.LOADING)
	fsm.add_transition(Id.MENU, Id.LOADING)
	fsm.add_transition(Id.LOADING, Id.COUNTDOWN)
	fsm.add_transition(Id.COUNTDOWN, Id.PLAYING)
	fsm.add_transition(Id.PLAYING, Id.PAUSED)
	fsm.add_transition(Id.PAUSED, Id.PLAYING)
	fsm.add_transition(Id.PLAYING, Id.RESULTS)
	fsm.add_transition(Id.RESULTS, Id.MENU)
	fsm.add_transition(Id.RESULTS, Id.LOADING)
	fsm.add_transition(Id.PAUSED, Id.RESULTS)
	
	fsm.request(Id.BOOT)

func request_transition(to_state: Id) -> void:
	fsm.request(to_state)

func current_state() -> Id:
	return fsm.get_current_state() as Id
