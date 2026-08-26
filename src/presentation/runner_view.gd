class_name RunnerView
extends Node2D

var loadout: Loadout
var sprite: Sprite2D

func _ready() -> void:
	sprite = Sprite2D.new()
	add_child(sprite)

func apply_cosmetics(l: Loadout, catalog: Catalog) -> void:
	loadout = l
	var skin_id = loadout.get_equipped(CosmeticItem.Type.SKIN)
	var item = catalog.get_item(skin_id)
	
	if item and item.texture_path:
		sprite.texture = load(item.texture_path)
		
	# Apply additive material logic based on item shader_path
	var mat = ShaderMaterial.new()
	mat.shader = load(item.shader_path if item.shader_path else "res://assets/shaders/runner.gdshader")
	sprite.material = mat
