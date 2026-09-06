class_name LatencyTest
extends Node

## Ferramenta de dev para medir latência toque -> mudança de direção (MOV-05, GSD 02
## MOVE-010). Mede três estágios por amostra: (1) timestamp do InputEvent bruto,
## (2) tick de simulação em que Runner.state.desired_direction efetivamente mudou,
## (3) primeiro _process() em que a RunnerView JÁ COMEÇOU a girar. Isso só produz número
## real rodando dentro de uma partida de verdade, num aparelho real — headless não tem
## touchscreen nem vsync. Anexe este nó como filho de MatchDirector durante uma partida
## real, sete `director` e `player_view` (a RunnerView do jogador), toque a tela 100 vezes
## alternando direção, e chame generate_report() (ver checkpoint do Plano 02-07).
##
## A amostra fecha na PRIMEIRA mudança visível de rotação, não quando o giro termina.
## `docs/gameplay/controls.md` define a meta como "latência toque -> mudança de direção
## < 50 ms": é tempo até o jogo começar a responder. Fechar a amostra só quando a view
## alcança a direção desejada mediria a duração do giro (a 540°/s, 90° levam 167 ms e
## 180° levam 333 ms) — um número que nunca poderia passar da meta e que mudaria sozinho
## se o turn_rate de balance.md mudasse, sem nenhuma piora de responsividade.

signal sample_recorded(latency_ms: float)

var director: MatchDirector
var player_view: InterpolatedVisual

var max_samples: int = 100
var _samples_ms: Array[float] = []

var _pending_event_time_usec: int = -1
var _pending_direction_before: Vector2 = Vector2.ZERO
var _pending_view_rotation_before: float = 0.0
var _waiting_for_visual_update: bool = false

## Menor giro considerado "mudança visível". Abaixo disso é ruído de ponto flutuante da
## interpolação, não resposta ao toque.
const VISIBLE_CHANGE_RAD: float = 0.0087  # ~0.5°


func _unhandled_input(event: InputEvent) -> void:
	if _samples_ms.size() >= max_samples or not director or not director.player_runner:
		return
	if _pending_event_time_usec == -1 and (event is InputEventScreenTouch or event is InputEventScreenDrag):
		_pending_event_time_usec = Time.get_ticks_usec()
		_pending_direction_before = director.player_runner.state.desired_direction
		_pending_view_rotation_before = player_view.curr_rotation if player_view else 0.0


func _physics_process(_delta: float) -> void:
	if _pending_event_time_usec == -1 or _waiting_for_visual_update:
		return
	if not director or not director.player_runner:
		return
	if director.player_runner.state.desired_direction != _pending_direction_before:
		_waiting_for_visual_update = true


func _process(_delta: float) -> void:
	if not _waiting_for_visual_update or not player_view or not director or not director.player_runner:
		return
	if absf(angle_difference(_pending_view_rotation_before, player_view.curr_rotation)) > VISIBLE_CHANGE_RAD:
		var total_usec := Time.get_ticks_usec() - _pending_event_time_usec
		_record_sample(total_usec / 1000.0)
		_reset_pending()


func _record_sample(latency_ms: float) -> void:
	_samples_ms.append(latency_ms)
	sample_recorded.emit(latency_ms)


func _reset_pending() -> void:
	_pending_event_time_usec = -1
	_waiting_for_visual_update = false


func sample_count() -> int:
	return _samples_ms.size()


static func percentile(samples: Array, p: float) -> float:
	if samples.is_empty():
		return -1.0
	var sorted_samples := samples.duplicate()
	sorted_samples.sort()
	var index := int(ceil(p * sorted_samples.size())) - 1
	index = clampi(index, 0, sorted_samples.size() - 1)
	return sorted_samples[index]


func generate_report() -> String:
	if _samples_ms.is_empty():
		return "sem amostras — rode este teste tocando a tela durante uma partida real"
	var p50 := percentile(_samples_ms, 0.5)
	var p95 := percentile(_samples_ms, 0.95)
	return "Latência (%d amostras) — p50: %.1f ms · p95: %.1f ms" % [_samples_ms.size(), p50, p95]
