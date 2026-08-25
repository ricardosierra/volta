class_name BackwashAnimation
extends Node

static func play(service: VfxService, center_pos: Vector2) -> void:
	service.play("backwash", center_pos, 0.8)
