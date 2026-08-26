class_name GameCamera
extends Camera2D

@export var smoothing_speed: float = 5.0
@export var lookahead_distance: float = 150.0

var target_visual: InterpolatedVisual
var arena: Arena

func _process(delta: float) -> void:
	if not target_visual or not arena:
		return
		
	# Lookahead based on current rotation
	var offset_vec = Vector2.RIGHT.rotated(target_visual.global_rotation) * lookahead_distance
	var desired_pos = target_visual.global_position + offset_vec
	
	# Clamp to arena limits if needed (simple version)
	var half_size = get_viewport_rect().size / 2.0 / zoom
	
	desired_pos.x = clamp(desired_pos.x, arena.limits.position.x + half_size.x, arena.limits.end.x - half_size.x)
	desired_pos.y = clamp(desired_pos.y, arena.limits.position.y + half_size.y, arena.limits.end.y - half_size.y)
	
	# Exponential smoothing
	global_position = global_position.lerp(desired_pos, 1.0 - exp(-smoothing_speed * delta))
