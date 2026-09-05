class_name VIcon
extends TextureRect

@export var icon_texture: Texture2D

func _ready() -> void:
	texture = icon_texture
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Apply additive blending so black backgrounds of raw JPGs disappear
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat
