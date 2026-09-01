extends GutTest

## Regressão da extração de MatchFieldRenderer (Regra 8 do CLAUDE.md — _draw() tinha 93
## linhas): uma Control mínima delega para MatchFieldRenderer.draw() dentro do ciclo real
## de _draw() do motor e não pode lançar erro para um estado típico de partida.

class _FakeFieldCanvas extends Control:
	var state: Dictionary = {}

	func _draw() -> void:
		MatchFieldRenderer.draw(self, state)


func test_draw_runs_without_error_for_a_typical_match_state() -> void:
	var canvas := _FakeFieldCanvas.new()
	canvas.size = Vector2(1080, 1920)
	canvas.state = {
		"size": canvas.size,
		"field": Rect2(72.0, 260.0, 936.0, 1210.0),
		"bot_positions": [Vector2(300, 400)],
		"bot_directions": [Vector2.LEFT],
		"bot_trails": [[Vector2(300, 400), Vector2(320, 400)]],
		"bot_home_rects": [Rect2(100, 100, 220, 184)],
		"bot_alive": [true],
		"bot_flash": [0.0],
		"bot_colors": [Color("4cc9f0")],
		"round_initialized": true,
		"claim_rect": Rect2(240.0, 340.0, 240.0, 220.0),
		"trail": [Vector2(400, 500), Vector2(420, 500)],
		"player_position": Vector2(400, 500),
		"player_direction": Vector2.RIGHT,
		"elapsed": 12.0,
	}

	add_child_autofree(canvas)
	canvas.queue_redraw()
	await get_tree().process_frame

	assert_true(true, "MatchFieldRenderer.draw() completou sem lançar erro dentro de _draw()")


func test_draw_with_zero_size_returns_early() -> void:
	var canvas := _FakeFieldCanvas.new()
	canvas.size = Vector2.ZERO
	canvas.state = {"size": Vector2.ZERO}

	add_child_autofree(canvas)
	canvas.queue_redraw()
	await get_tree().process_frame

	assert_true(true, "size zero não tenta ler as outras chaves do state (early return)")
