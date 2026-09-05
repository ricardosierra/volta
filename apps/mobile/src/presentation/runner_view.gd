class_name RunnerView
extends InterpolatedVisual

## Representação visual de um Runner. Estende InterpolatedVisual (o componente único de
## interpolação de ADR-0014) em vez de reimplementar prev/curr — amostra Runner.state a
## cada _physics_process (mesma cadência da simulação) e deixa a interpolação para o
## _process() herdado.

var runner: Runner
var loadout: Loadout
var sprite: Sprite2D

func _ready() -> void:
	super._ready()
	sprite = Sprite2D.new()
	add_child(sprite)

func _physics_process(_delta: float) -> void:
	if runner:
		update_simulation_state(runner.state.position, runner.state.direction.angle())

func apply_cosmetics(l: Loadout, catalog: Catalog) -> void:
	loadout = l
	var skin_id := loadout.get_equipped(CosmeticItem.Type.SKIN)
	var item := catalog.get_item(skin_id)

	if item and item.texture_path:
		sprite.texture = load(item.texture_path)

	var mat := ShaderMaterial.new()
	mat.shader = load(item.shader_path if item.shader_path else "res://assets/shaders/runner.gdshader")
	sprite.material = mat
	queue_redraw()

func _draw() -> void:
	if sprite and sprite.texture:
		return
	# PLACEHOLDER-ART-001: círculo branco provisório enquanto não há cosmético equipado. Replacement: GSD 08
	draw_circle(Vector2.ZERO, 16.0, Color.WHITE)
