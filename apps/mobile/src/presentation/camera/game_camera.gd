class_name GameCamera
extends Camera2D

## Segue o Runner do jogador sobre a posição INTERPOLADA (nunca a de simulação — ADR-0014).
## Os números vêm de CameraBalance (docs/design/balance.md §11) via setup(), nunca de
## @export inventado: os defaults antigos (5.0/150.0) nunca bateram com o documento.

var target_visual: InterpolatedVisual
var arena: Arena

var _follow_smoothing: float = 8.0
var _lookahead_distance: float = 90.0
var _balance: CameraBalance

func setup(balance: CameraBalance, game_arena: Arena) -> void:
	_follow_smoothing = balance.follow_smoothing
	_lookahead_distance = balance.lookahead
	_balance = balance
	arena = game_arena
	frame_to(get_viewport_rect())


## Enquadra o jogo na área REALMENTE útil, medida em execução — a faixa entre a HUD de cima
## e a de baixo, não um número de pixels escrito à mão (regra de enquadramento do
## Jogos/CLAUDE.md). Converte "mostrar N × M células" de CameraBalance no zoom de Camera2D
## para esta tela, e desloca a câmera para que o alvo seguido fique no centro dessa faixa, e
## não no centro da viewport (onde a HUD o cobriria).
##
## Antes disto, setup() fazia `zoom = Vector2(zoom_base, zoom_base)`: aplicava um número
## relativo de design como valor absoluto de engine. Num 2340×1080 isso mostrava 146 × 67
## células em vez das 42 × 24 de balance.md §11 — tudo minúsculo e ilegível.
func frame_to(usable_rect: Rect2) -> void:
	if not _balance or not arena or not arena.definition:
		return
	if usable_rect.size.x <= 0.0 or usable_rect.size.y <= 0.0:
		return

	var cell := arena.definition.cell_size
	var wanted := Vector2(_balance.visible_cells_x * cell, _balance.visible_cells_y * cell)
	if wanted.x <= 0.0 or wanted.y <= 0.0:
		return

	# min() garante que o enquadramento pedido cabe nos DOIS eixos; o eixo folgado mostra um
	# pouco mais, nunca menos (balance.md diz "≈").
	var fit := minf(usable_rect.size.x / wanted.x, usable_rect.size.y / wanted.y)
	var scale_factor := fit * _balance.zoom_base
	zoom = Vector2(scale_factor, scale_factor)

	# O alvo deve aparecer no centro da faixa útil. offset é em unidades de mundo.
	var viewport_center := get_viewport_rect().size / 2.0
	offset = (viewport_center - usable_rect.get_center()) / scale_factor

func _process(delta: float) -> void:
	if not target_visual or not arena:
		return

	var offset_vec := Vector2.RIGHT.rotated(target_visual.global_rotation) * _lookahead_distance
	var desired_pos := target_visual.global_position + offset_vec

	var half_size := get_viewport_rect().size / 2.0 / zoom
	desired_pos.x = _clamp_to_arena_axis(desired_pos.x, arena.limits.position.x, arena.limits.end.x, half_size.x)
	desired_pos.y = _clamp_to_arena_axis(desired_pos.y, arena.limits.position.y, arena.limits.end.y, half_size.y)

	global_position = global_position.lerp(desired_pos, 1.0 - exp(-_follow_smoothing * delta))

## Confina um eixo da câmera dentro de [min_limit, max_limit], compensando a metade da
## viewport (half_extent) para nunca revelar área fora da Arena. Quando a Arena é menor que
## a viewport (half_extent maior que a metade da Arena nesse eixo), não há posição de câmera
## que evite mostrar além da borda — nesse caso centraliza no meio da Arena em vez de colar
## num canto arbitrário do clamp invertido.
func _clamp_to_arena_axis(value: float, min_limit: float, max_limit: float, half_extent: float) -> float:
	var low := min_limit + half_extent
	var high := max_limit - half_extent
	if low > high:
		return (min_limit + max_limit) / 2.0
	return clamp(value, low, high)
