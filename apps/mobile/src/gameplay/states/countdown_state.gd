class_name CountdownState
extends State

var timer: float = 3.0
var _match_director: MatchDirector

func _init(director: MatchDirector) -> void:
	_match_director = director

func enter() -> void:
	timer = 3.0
	Log.info(Log.Category.GAMEPLAY, "3.. 2.. 1..")

func update(delta: float) -> void:
	# Input is processed (router stores buffer), but movement doesn't happen
	timer -= delta
	if timer <= 0:
		_match_director.game_state.request_transition(GameState.Id.PLAYING)
