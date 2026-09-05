extends Control

var screen_stack: ScreenStack
var _match_director: MatchDirector
var _runner_view_spawner: RunnerViewSpawner
var _input_router: InputRouter
var _game_camera: GameCamera
var _config: ConfigService

func _ready() -> void:
	var ui_layer := CanvasLayer.new()
	add_child(ui_layer)

	screen_stack = ScreenStack.new()
	ui_layer.add_child(screen_stack)
	screen_stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_config = Bootstrap.registry.resolve("config") as ConfigService

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

	var arena_definition := load("res://resources/arenas/open_field.tres") as ArenaDefinition

	_input_router = InputRouter.new()
	add_child(_input_router)

	_match_director = MatchDirector.new()
	add_child(_match_director)
	_match_director.configure(_config, arena_definition, _input_router)

	_runner_view_spawner = RunnerViewSpawner.new()
	add_child(_runner_view_spawner)
	_runner_view_spawner.watch(_match_director)

	_game_camera = GameCamera.new()
	add_child(_game_camera)
	if _config:
		_game_camera.setup(_config.camera(), _match_director.arena)
	_game_camera.make_current()

	var config := Resource.new()
	config.set_meta("bot_count", 3)
	_match_director.setup_match(config)
	match_screen.set_bot_count(3)

	for view in _runner_view_spawner.get_children():
		if view.runner == _match_director.player_runner:
			_game_camera.target_visual = view
			break

	match_screen.set_match_director(_match_director)
	match_screen.set_input_router(_input_router)

func _return_to_menu() -> void:
	if is_instance_valid(_match_director):
		_match_director.queue_free()
		_match_director = null

	if is_instance_valid(_runner_view_spawner):
		_runner_view_spawner.queue_free()
		_runner_view_spawner = null

	if is_instance_valid(_input_router):
		_input_router.queue_free()
		_input_router = null

	if is_instance_valid(_game_camera):
		_game_camera.queue_free()
		_game_camera = null

	if screen_stack and screen_stack.can_pop():
		screen_stack.pop()
