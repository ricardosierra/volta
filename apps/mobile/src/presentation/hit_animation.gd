class_name HitAnimation
extends Node

static func play(service: VfxService, center_pos: Vector2) -> void:
	service.play("hit", center_pos, 1.0)
