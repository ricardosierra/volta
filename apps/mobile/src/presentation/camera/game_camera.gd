class_name GameCamera
extends Camera2D

## Segue o Runner do jogador sobre a posição INTERPOLADA (nunca a de simulação — ADR-0014).
## Os números vêm de CameraBalance (docs/design/balance.md §11) via setup(), nunca de
## @export inventado: os defaults antigos (5.0/150.0) nunca bateram com o documento.

var target_visual: InterpolatedVisual
var arena: Arena

var _follow_smoothing: float = 8.0
var _lookahead_distance: float = 90.0

func setup(balance: CameraBalance, game_arena: Arena) -> void:
	_follow_smoothing = balance.follow_smoothing
	_lookahead_distance = balance.lookahead
	zoom = Vector2(balance.zoom_base, balance.zoom_base)
	arena = game_arena

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
