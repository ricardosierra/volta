class_name RunnerView
extends Node2D

@export var radius: float = 16.0
var interp_visual: InterpolatedVisual

func _ready() -> void:
	interp_visual = InterpolatedVisual.new()
	add_child(interp_visual)

func update_from_sim(pos: Vector2, rot: float) -> void:
	if interp_visual:
		interp_visual.update_simulation_state(pos, rot)
		queue_redraw()

func _draw() -> void:
	# PLACEHOLDER-ART-001 / Replacement: GSD 08
	# Draw relative to the interpolated visual's position
	if interp_visual:
		draw_set_transform(interp_visual.position, interp_visual.rotation, Vector2.ONE)
		draw_circle(Vector2.ZERO, radius, Color.WHITE)
		draw_line(Vector2.ZERO, Vector2.RIGHT * radius, Color.RED, 2.0)
