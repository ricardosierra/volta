extends Control

var screen_stack: ScreenStack
var _match_director: MatchDirector
var _runner_view_spawner: RunnerViewSpawner

func _ready() -> void:
	screen_stack = ScreenStack.new()
	add_child(screen_stack)
	screen_stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var splash := SplashScreen.new()
	splash.finished.connect(_show_main_menu)
	screen_stack.push(splash)

func _show_main_menu() -> void:
	var menu := MainMenuScreen.new()
	menu.play_requested.connect(_start_match)
	screen_stack.replace_root(menu)

func _start_match() -> void:
	if is_instance_valid(_match_director):
		return

	var match_screen := MatchScreen.new()
	match_screen.exit_requested.connect(_return_to_menu)
	screen_stack.push(match_screen)

	_match_director = MatchDirector.new()
	add_child(_match_director)

	_runner_view_spawner = RunnerViewSpawner.new()
	add_child(_runner_view_spawner)
	_runner_view_spawner.watch(_match_director)

	var config := Resource.new()
	config.set_meta("bot_count", 3)
	_match_director.setup_match(config)
	match_screen.set_bot_count(3)
	
	# Start clock/process
	set_process(true)

func _return_to_menu() -> void:
	if is_instance_valid(_match_director):
		_match_director.queue_free()
		_match_director = null

	if is_instance_valid(_runner_view_spawner):
		_runner_view_spawner.queue_free()
		_runner_view_spawner = null

	if screen_stack and screen_stack.can_pop():
		screen_stack.pop()
