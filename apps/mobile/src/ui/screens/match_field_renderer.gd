class_name MatchFieldRenderer
extends RefCounted

## Desenha o campo, os bots, o claim, o trail e o jogador de MatchScreen. Extraído por
## tamanho de função (Regra 8 do CLAUDE.md — _draw() tinha 93 linhas). Pura leitura de
## estado via CanvasItem.draw_*, chamado de dentro do _draw() real de MatchScreen (Godot só
## permite draw_* durante o callback _draw() do próprio nó).

static func draw(canvas: CanvasItem, state: Dictionary) -> void:
	var size: Vector2 = state["size"]
	if size.x <= 0.0 or size.y <= 0.0:
		return

	_draw_background(canvas, state)
	_draw_field(canvas, state)
	_draw_bot_homes_and_trails(canvas, state)
	_draw_claim_and_trail(canvas, state)
	_draw_runners(canvas, state)
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


static func _draw_bot_homes_and_trails(canvas: CanvasItem, state: Dictionary) -> void:
	var bot_positions: Array = state["bot_positions"]
	var bot_alive: Array = state["bot_alive"]
	var bot_home_rects: Array = state["bot_home_rects"]
	var bot_trails: Array = state["bot_trails"]
	var bot_colors: Array = state["bot_colors"]

	for index in range(bot_positions.size()):
		if not bot_alive[index]:
			continue
		var home: Rect2 = bot_home_rects[index]
		var bot_color: Color = bot_colors[index % bot_colors.size()]
		canvas.draw_rect(home, Color(bot_color, 0.035))
		canvas.draw_rect(home, Color(bot_color, 0.28), false, 2.0)
		var bot_trail: Array = bot_trails[index]
		if bot_trail.size() > 1:
			canvas.draw_polyline(PackedVector2Array(bot_trail), Color(0.0, 0.0, 0.0, 0.35), 18.0, true)
			canvas.draw_polyline(PackedVector2Array(bot_trail), Color(bot_color, 0.82), 8.0, true)
			canvas.draw_polyline(PackedVector2Array(bot_trail), Color(bot_color, 0.20), 22.0, true)


static func _draw_claim_and_trail(canvas: CanvasItem, state: Dictionary) -> void:
	if state["round_initialized"]:
		var claim_rect: Rect2 = state["claim_rect"]
		canvas.draw_rect(claim_rect.grow(8.0), Color("0b766f"), false, 8.0)
		canvas.draw_rect(claim_rect, Color(0.12, 0.68, 0.60, 0.20))
		canvas.draw_rect(claim_rect, Color("57e6d0"), false, 3.0)
		for stripe in range(-2, 8):
			var stripe_start := Vector2(claim_rect.position.x + float(stripe) * 90.0, claim_rect.end.y)
			var stripe_end := stripe_start + Vector2(220.0, -220.0)
			canvas.draw_line(stripe_start, stripe_end, Color(0.34, 0.95, 0.84, 0.12), 3.0)

	var trail: Array = state["trail"]
	if trail.size() > 1:
		canvas.draw_polyline(PackedVector2Array(trail), Color(0.0, 0.0, 0.0, 0.42), 22.0, true)
		canvas.draw_polyline(PackedVector2Array(trail), Color("f9c74f"), 11.0, true)
		canvas.draw_polyline(PackedVector2Array(trail), Color("fff3b0"), 3.0, true)


static func _draw_runners(canvas: CanvasItem, state: Dictionary) -> void:
	var bot_positions: Array = state["bot_positions"]
	var bot_alive: Array = state["bot_alive"]
	var bot_flash: Array = state["bot_flash"]
	var bot_colors: Array = state["bot_colors"]
	var bot_directions: Array = state["bot_directions"]

	for index in range(bot_positions.size()):
		var bot_color: Color = bot_colors[index % bot_colors.size()]
		if bot_alive[index]:
			_draw_bot(canvas, bot_positions[index], bot_color, MatchScreen.BOT_RADIUS, bot_directions[index])
		elif bot_flash[index] > 0.0:
			_draw_eliminated_bot(canvas, bot_positions[index], bot_color, bot_flash[index])

	if state["round_initialized"]:
		var player_position: Vector2 = state["player_position"]
		var player_direction: Vector2 = state["player_direction"]
		var elapsed: float = state["elapsed"]
		var pulse := 4.0 + sin(elapsed * 7.0) * 3.0
		canvas.draw_circle(player_position, MatchScreen.PLAYER_RADIUS + 16.0 + pulse, Color(0.98, 0.78, 0.31, 0.10))
		canvas.draw_circle(player_position, MatchScreen.PLAYER_RADIUS + 7.0, Color("f9c74f"), false, 3.0)
		canvas.draw_circle(player_position, MatchScreen.PLAYER_RADIUS, Color("f9c74f"))
		canvas.draw_line(
			player_position,
			player_position + player_direction * 42.0,
			Color("fff3b0"),
			5.0,
			true
		)


static func _draw_bot(canvas: CanvasItem, position: Vector2, color: Color, radius: float, direction: Vector2) -> void:
	canvas.draw_circle(position, radius + 16.0, Color(color, 0.10))
	canvas.draw_circle(position, radius + 7.0, Color(color, 0.24), false, 3.0)
	canvas.draw_circle(position, radius, color)
	canvas.draw_line(position, position + direction * 32.0, Color("f4fbff"), 4.0, true)


static func _draw_eliminated_bot(canvas: CanvasItem, position: Vector2, color: Color, strength: float) -> void:
	var radius := MatchScreen.BOT_RADIUS + (1.0 - strength) * 24.0
	canvas.draw_circle(position, radius, Color(color, strength * 0.16), false, 4.0)
	canvas.draw_line(
		position - Vector2(radius, radius),
		position + Vector2(radius, radius),
		Color("ff6b6b", strength),
		5.0,
		true
	)
	canvas.draw_line(
		position + Vector2(-radius, radius),
		position + Vector2(radius, -radius),
		Color("ff6b6b", strength),
		5.0,
		true
	)


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
