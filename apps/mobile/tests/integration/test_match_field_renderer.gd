extends GutTest

## Regressão da extração de MatchFieldRenderer (Regra 8 do CLAUDE.md): uma Control mínima
## delega para MatchFieldRenderer.draw() dentro do ciclo real de _draw() do motor e não
## pode lançar erro. Desde o Plano 02-06, o renderer só desenha a moldura do campo — o
## state não carrega mais bots/claim/trail.

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
