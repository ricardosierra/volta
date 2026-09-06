class_name MatchFieldRenderer
extends RefCounted

## Desenha a moldura de HUD de MatchScreen. Extraído por tamanho de função (Regra 8 do
## CLAUDE.md).
##
## Desde o Plano 02-06 (Fase 2) os Runners não são mais desenhados aqui — as RunnerView
## reais (apps/mobile/src/presentation/runner_view.gd), sob a GameCamera real, já os mostram.
##
## Desde o Plano 02-07: este renderer NUNCA pinta área opaca sobre a área de jogo. A
## MatchScreen vive num CanvasLayer, que desenha por cima do mundo 2D — o fundo de viewport
## inteira que existia aqui (#050b15) e o preenchimento do campo (#091f2d) escondiam a
## partida inteira. No aparelho aparecia só um retângulo vazio, sem jogador e sem inimigos.
## As faixas de HUD são translúcidas de propósito: o jogo ocupa a tela e a interface flutua
## por cima.

## Opacidade das faixas de HUD. Alta o bastante para o texto ler, baixa o bastante para o
## jogo continuar visível atrás.
const BAND_ALPHA: float = 0.72


static func draw(canvas: CanvasItem, state: Dictionary) -> void:
	var size: Vector2 = state["size"]
	if size.x <= 0.0 or size.y <= 0.0:
		return

	_draw_header_band(canvas, state)
	_draw_play_area_frame(canvas, state)
	_draw_footer_band(canvas, state)


static func _draw_header_band(canvas: CanvasItem, state: Dictionary) -> void:
	var size: Vector2 = state["size"]
	var header := Rect2(MatchScreen.PANEL_MARGIN, 28.0, size.x - MatchScreen.PANEL_MARGIN * 2.0, 190.0)
	canvas.draw_rect(header, Color("0a1726", BAND_ALPHA))
	canvas.draw_rect(Rect2(header.position, Vector2(6.0, header.size.y)), Color("2dd4bf"))
	canvas.draw_line(
		Vector2(header.position.x + 28.0, header.end.y - 2.0),
		Vector2(header.end.x - 28.0, header.end.y - 2.0),
		Color("1d3d56"),
		2.0
	)


static func _draw_play_area_frame(canvas: CanvasItem, state: Dictionary) -> void:
	# Só contorno e cantos: o interior é o mundo real, visto pela GameCamera. Preencher
	# aqui é o bug que o Plano 02-07 corrigiu.
	var field: Rect2 = state["field"]
	canvas.draw_rect(field, Color("2dd4bf", 0.55), false, 3.0)
	_draw_field_brackets(canvas, field)


static func _draw_field_brackets(canvas: CanvasItem, field: Rect2) -> void:
	var length := 34.0
	var color := Color("65f4df")
	var left := field.position.x
	var right := field.end.x
	var top := field.position.y
	var bottom := field.end.y

	canvas.draw_line(Vector2(left, top + length), Vector2(left, top), color, 5.0)
	canvas.draw_line(Vector2(left, top), Vector2(left + length, top), color, 5.0)
	canvas.draw_line(Vector2(right - length, top), Vector2(right, top), color, 5.0)
	canvas.draw_line(Vector2(right, top), Vector2(right, top + length), color, 5.0)
	canvas.draw_line(Vector2(left, bottom - length), Vector2(left, bottom), color, 5.0)
	canvas.draw_line(Vector2(left, bottom), Vector2(left + length, bottom), color, 5.0)
	canvas.draw_line(Vector2(right - length, bottom), Vector2(right, bottom), color, 5.0)
	canvas.draw_line(Vector2(right, bottom - length), Vector2(right, bottom), color, 5.0)


static func _draw_footer_band(canvas: CanvasItem, state: Dictionary) -> void:
	var size: Vector2 = state["size"]
	var footer := Rect2(MatchScreen.PANEL_MARGIN, MatchScreen.FIELD_BOTTOM + 58.0, size.x - MatchScreen.PANEL_MARGIN * 2.0, 160.0)
	canvas.draw_rect(footer, Color("081521", BAND_ALPHA))
	canvas.draw_line(
		Vector2(footer.position.x + 24.0, footer.position.y),
		Vector2(footer.end.x - 24.0, footer.position.y),
		Color("1d3d56"),
		2.0
	)
