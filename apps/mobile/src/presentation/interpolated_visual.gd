class_name InterpolatedVisual
extends Node2D

var prev_position: Vector2
var curr_position: Vector2
var prev_rotation: float
var curr_rotation: float

func _ready() -> void:
	# Ensure this runs in the process frame
	set_process(true)
	
	prev_position = global_position
	curr_position = global_position
	prev_rotation = global_rotation
	curr_rotation = global_rotation

func update_simulation_state(new_pos: Vector2, new_rot: float) -> void:
	prev_position = curr_position
	prev_rotation = curr_rotation
	
	curr_position = new_pos
	curr_rotation = new_rot

func _process(_delta: float) -> void:
	var fraction := Engine.get_physics_interpolation_fraction()
	
	global_position = prev_position.lerp(curr_position, fraction)
	global_rotation = lerp_angle(prev_rotation, curr_rotation, fraction)
