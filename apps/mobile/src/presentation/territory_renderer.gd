class_name TerritoryRenderer
extends Node2D

var arena: ArenaDefinition

func set_arena(a: ArenaDefinition) -> void:
	arena = a
	queue_redraw()

func _draw() -> void:
	if not arena:
		return
		
	# Draw blocks
	for r in arena.blocked_rects:
		draw_rect(r, Color(0.2, 0.2, 0.2, 0.8))
		
	# Draw hazards
	for r in arena.hazard_rects:
		draw_rect(r, Color(1.0, 0.0, 0.0, 0.5))
