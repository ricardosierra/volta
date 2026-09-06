class_name ArenaView
extends Node2D

## Desenha o chão e a borda da Arena em coordenadas de MUNDO, sob os Runners.
##
## Sem isto a partida rodava sobre o cinza padrão do Godot: o Runner se movia, a câmera o
## seguia, e na tela nada mudava — não havia referência estática para o olho perceber
## movimento. "Câmera que ninguém percebe" (meta da Fase 2) não é verificável sem isso.
##
## Lê `Arena` (simulação) e nada mais; a simulação continua sem saber que esta classe existe.
## O território capturado NÃO é desenhado aqui — é da Fase 3 (TER-*), com render de custo
## constante em 1 draw call. Aqui é só o campo vazio.

## Espaçamento da grade em células. 8 dá uma malha legível sem virar textura de ruído nas
## 42 células que a câmera enquadra.
const GRID_STEP_CELLS: int = 8

var arena: Arena


func setup(game_arena: Arena) -> void:
	arena = game_arena
	# Fica atrás de qualquer RunnerView, que são irmãos adicionados depois.
	z_index = -100
	queue_redraw()


func _draw() -> void:
	if not arena:
		return

	var limits := arena.limits
	draw_rect(limits, Color("0b1a26"))
	_draw_grid(limits)
	draw_rect(limits, Color("2dd4bf", 0.85), false, 6.0)


func _draw_grid(limits: Rect2) -> void:
	if not arena.definition:
		return
	var step := arena.definition.cell_size * float(GRID_STEP_CELLS)
	if step <= 0.0:
		return

	var line_color := Color(0.18, 0.55, 0.60, 0.22)
	var x := limits.position.x + step
	while x < limits.end.x:
		draw_line(Vector2(x, limits.position.y), Vector2(x, limits.end.y), line_color, 2.0)
		x += step

	var y := limits.position.y + step
	while y < limits.end.y:
		draw_line(Vector2(limits.position.x, y), Vector2(limits.end.x, y), line_color, 2.0)
		y += step
