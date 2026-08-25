class_name SettingsControls
extends Control

signal driver_changed(new_driver: InputDriver)

func _ready() -> void:
	# UI for test driving controls (placeholder)
	var vbox = VBoxContainer.new()
	add_child(vbox)
	
	var btn_swipe = Button.new()
	btn_swipe.text = "Swipe"
	btn_swipe.pressed.connect(func(): driver_changed.emit(SwipeDriver.new()))
	vbox.add_child(btn_swipe)
	
	var btn_joy = Button.new()
	btn_joy.text = "Joystick"
	btn_joy.pressed.connect(func(): driver_changed.emit(JoystickDriver.new()))
	vbox.add_child(btn_joy)
	
	var btn_rel = Button.new()
	btn_rel.text = "Relative"
	btn_rel.pressed.connect(func(): driver_changed.emit(RelativeDriver.new()))
	vbox.add_child(btn_rel)
