class_name MatchFieldRenderer
extends RefCounted

## Desenha a moldura do campo de MatchScreen. Extraído por tamanho de função (Regra 8 do
## CLAUDE.md). Desde o Plano 02-06 (Fase 2): Runners não são mais desenhados aqui — as
## RunnerView reais (apps/mobile/src/presentation/runner_view.gd), sob a GameCamera real,
## já os mostram. Este renderer só desenha a moldura estática do campo.

static func draw(canvas: CanvasItem, state: Dictionary) -> void:
	var size: Vector2 = state["size"]
	if size.x <= 0.0 or size.y <= 0.0:
		return

	_draw_background(canvas, state)
	_draw_field(canvas, state)
	_draw_footer(canvas, state)


static func _draw_background(canvas: CanvasItem, state: Dictionary) -> void:
	var size: Vector2 = state["size"]
	var viewport_rect := Rect2(Vector2.ZERO, size)
	canvas.draw_rect(viewport_rect, Color("050b15"))

	for diagonal in range(-8, 18):
		var start := Vector2(float(diagonal) * 160.0, 0.0)
		canvas.draw_line(start, start + Vector2(-size.y * 0.42, size.y), Color(0.08, 0.20, 0.30, 0.18), 2.0)

	var header := Rect2(MatchScreen.PANEL_MARGIN, 28.0, size.x - MatchScreen.PANEL_MARGIN * 2.0, 190.0)
	canvas.draw_rect(header, Color("0a1726"))
	canvas.draw_rect(Rect2(header.position, Vector2(6.0, header.size.y)), Color("2dd4bf"))
	canvas.draw_line(
		Vector2(header.position.x + 28.0, header.end.y - 2.0),
		Vector2(header.end.x - 28.0, header.end.y - 2.0),
		Color("1d3d56"),
		2.0
	)


static func _draw_field(canvas: CanvasItem, state: Dictionary) -> void:
	var field: Rect2 = state["field"]
	canvas.draw_rect(field.grow(24.0), Color(0.0, 0.0, 0.0, 0.26))
	canvas.draw_rect(field.grow(12.0), Color("0a1a29"))
	canvas.draw_rect(field, Color("091f2d"))
	canvas.draw_rect(field, Color("2dd4bf"), false, 3.0)

	for column in range(1, 12):
		var x := field.position.x + field.size.x * float(column) / 12.0
		canvas.draw_line(Vector2(x, field.position.y), Vector2(x, field.end.y), Color(0.15, 0.52, 0.58, 0.16), 1.0)
	for row in range(1, 13):
		var y := field.position.y + field.size.y * float(row) / 13.0
		canvas.draw_line(Vector2(field.position.x, y), Vector2(field.end.x, y), Color(0.15, 0.52, 0.58, 0.16), 1.0)

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


static func _draw_footer(canvas: CanvasItem, state: Dictionary) -> void:
	var size: Vector2 = state["size"]
	var footer := Rect2(MatchScreen.PANEL_MARGIN, MatchScreen.FIELD_BOTTOM + 58.0, size.x - MatchScreen.PANEL_MARGIN * 2.0, 160.0)
	canvas.draw_rect(footer, Color("081521"))
	canvas.draw_line(
		Vector2(footer.position.x + 24.0, footer.position.y),
		Vector2(footer.end.x - 24.0, footer.position.y),
		Color("1d3d56"),
		2.0
	)
