class_name ScreenStack
extends Control

var _stack: Array[Screen] = []

func push(screen: Screen, args: Dictionary = {}) -> void:
	if _stack.size() > 0:
		_stack.back().on_focus_lost()
		_stack.back().hide()
		
	_stack.append(screen)
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.on_pushed(args)
	screen.show()
	screen.on_focus_gained()


func replace_root(screen: Screen, args: Dictionary = {}) -> void:
	while not _stack.is_empty():
		var current: Screen = _stack.pop_back()
		current.on_focus_lost()
		current.on_popped()
		current.queue_free()
	push(screen, args)


func pop() -> void:
	if _stack.size() > 1:
		var current = _stack.pop_back()
		current.on_focus_lost()
		current.on_popped()
		current.queue_free()
		
		_stack.back().show()
		_stack.back().on_focus_gained()

func can_pop() -> bool:
	return _stack.size() > 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE):
		if _stack.size() > 0:
			var current = _stack.back()
			if not current.handle_back_button():
				if _stack.size() > 1:
					pop()
					get_viewport().set_input_as_handled()
