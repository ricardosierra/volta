class_name CountdownView
extends Control

var state: CountdownState
var label: Label

func _ready() -> void:
	label = Label.new()
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label.add_theme_font_size_override("font_size", 64)
	add_child(label)

func _process(_delta: float) -> void:
	if state and state.timer > 0:
		label.text = str(ceil(state.timer))
		show()
	else:
		hide()
