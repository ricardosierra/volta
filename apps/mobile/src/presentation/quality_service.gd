class_name QualityService
extends Node

var current_preset: Resource

func apply_preset(preset: Resource) -> void:
	current_preset = preset
	var scale: float = preset.get_meta("resolution_scale", 1.0)
	get_viewport().scaling_3d_scale = scale # Assuming 3D or 2D viewport scaling
	
	# Pass shader complexity to global shader parameters
	RenderingServer.global_shader_parameter_set("complexity", preset.get_meta("shader_complexity", 1))

func can_play_vfx() -> bool:
	if not current_preset: return true
	return current_preset.get_meta("enable_vfx_videos", true)

func set_refresh_rate(limit: int) -> void:
	# 0 = unlocked (V-Sync), 60, 90, 120
	Engine.max_fps = limit
	# The physics simulation stays at 60Hz via MatchDirector / PhysicsTicks
