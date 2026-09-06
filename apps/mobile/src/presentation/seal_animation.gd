class_name SealAnimation
extends Node

static func play(service: VfxService, center_pos: Vector2, area_size: int) -> void:
	var scale_factor: float = clamp(area_size / 50.0, 0.5, 3.0)
	service.play("seal", center_pos, scale_factor)
