extends Node

var screen_stack: ScreenStack

func _ready() -> void:
	screen_stack = ScreenStack.new()
	screen_stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen_stack)
	
	var splash = SplashScreen.new()
	screen_stack.push(splash)
	
	var t = create_tween()
	t.tween_interval(1.0)
	t.tween_callback(self._show_main_menu)

func _show_main_menu() -> void:
	var menu = MainMenuScreen.new()
	menu.play_requested.connect(_start_match)
	screen_stack.push(menu)

func _start_match() -> void:
	screen_stack.hide()
	
	var director = MatchDirector.new()
	add_child(director)
	
	var config = Resource.new()
	config.set_meta("bot_count", 3)
	director.setup_match(config)
	
	# Start clock/process
	set_process(true)
