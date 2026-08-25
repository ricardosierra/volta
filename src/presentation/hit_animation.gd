class_name HitAnimation
extends Node

static func play(parent: Node, center_pos: Vector2) -> void:
	var vfx = VideoVFXPlayer.new()
	parent.add_child(vfx)
	vfx.play_vfx("res://assets/raw/vfx/break.mp4", center_pos, 1.0)
