class_name VideoVFXPlayer
extends VideoStreamPlayer

func _ready() -> void:
	# Enable Additive Blending via Material to drop the black background of MP4s
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat
	
	expand = true
	# Auto-free when finished
	finished.connect(queue_free)

func play_vfx(stream_path: String, world_pos: Vector2, size_scale: float = 1.0) -> void:
	var v_stream := load(stream_path)
	if v_stream:
		stream = v_stream
		
		# Assuming standard size 512x512 for VFX
		custom_minimum_size = Vector2(512, 512) * size_scale
		size = custom_minimum_size
		position = world_pos - (size / 2.0)
		
		play()
	else:
		queue_free()
