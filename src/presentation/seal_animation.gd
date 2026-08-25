class_name SealAnimation
extends Node

static func play(parent: Node, center_pos: Vector2, area_size: int) -> void:
	var vfx = VideoVFXPlayer.new()
	parent.add_child(vfx)
	
	# Scale based on how big the capture was
	var scale_factor = clamp(area_size / 50.0, 0.5, 3.0)
	vfx.play_vfx("res://assets/raw/vfx/seal.mp4", center_pos, scale_factor)
