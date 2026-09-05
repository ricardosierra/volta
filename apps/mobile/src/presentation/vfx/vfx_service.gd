class_name VfxService
extends Node

var _pools: Dictionary = {} # String ID -> VfxPool
var quality: QualityService

func _ready() -> void:
	pass

func register_pool(id: String, scene: PackedScene, base_size: int) -> void:
	var actual_size := base_size
	# Scale by quality settings
	if quality and quality.current_preset:
		if not quality.current_preset.get_meta("enable_vfx_videos", true):
			actual_size = 0 # Disabled on low
	
	if actual_size > 0:
		_pools[id] = VfxPool.new(scene, actual_size, self)

func play(id: String, world_pos: Vector2, scale_mod: float = 1.0) -> void:
	if not _pools.has(id): return
	
	var instance: Node = _pools[id].get_instance()
	if instance:
		if instance.has_method("play_vfx"):
			instance.play_vfx(world_pos, scale_mod)
