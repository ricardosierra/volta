class_name MatchScreen
extends Screen

signal restart_requested
signal match_finished(won: bool)

const FIELD_MARGIN: float = 72.0
const FIELD_TOP: float = 260.0
const FIELD_BOTTOM: float = 1470.0
const PANEL_MARGIN: float = 48.0
const PLAYER_RADIUS: float = 28.0
const BOT_RADIUS: float = 26.0
const PLAYER_SPEED: float = 340.0
const BOT_SPEED: float = 205.0
const TRAIL_MIN_DISTANCE: float = 6.0
const BOT_TRAIL_MAX_POINTS: int = 320
const WIN_TERRITORY_PERCENT: float = 78.0
const MIN_TOUCH_TARGET_HEIGHT: float = 136.0

enum Phase { COUNTDOWN, PLAYING, RESULT }

var _phase: Phase = Phase.COUNTDOWN
var _countdown_remaining: float = 3.0
var _countdown_banner_remaining: float = 0.0
var _elapsed: float = 0.0
var _bot_count: int = 0
var _round_number: int = 1
var _round_initialized: bool = false
var _drawing_trail: bool = false
var _player_position: Vector2 = Vector2.ZERO
var _player_direction: Vector2 = Vector2.RIGHT
var _gesture_direction: Vector2 = Vector2.ZERO
var _gesture_start: Vector2 = Vector2.ZERO
var _gesture_active: bool = false
var _mouse_active: bool = false
var _trail: Array[Vector2] = []
var _claim_rect: Rect2 = Rect2()
var _territory_percent: float = 0.0
var _capture_count: int = 0
var _kill_count: int = 0
var _feedback_text: String = ""
var _feedback_remaining: float = 0.0

var _bot_positions: Array[Vector2] = []
var _bot_directions: Array[Vector2] = []
var _bot_trails: Array = []
var _bot_home_rects: Array[Rect2] = []
var _bot_alive: Array[bool] = []
var _bot_outside: Array[bool] = []
var _bot_flash: Array[float] = []

var _bot_names: Array[String] = ["NOVA", "PULSE", "RUSH", "VOID"]
var _bot_colors: Array[Color] = [
	Color("4cc9f0"),
	Color("ff4d9d"),
	Color("9be564"),
	Color("b98cff")
]

var _territory_label: Label
var _kills_label: Label
var _opponents_label: Label
var _time_label: Label
var _status_label: Label
var _countdown_label: Label
var _hint_label: Label
var _territory_bar: ProgressBar
var _top_bar: HBoxContainer
var _actions: CenterContainer
var _result_overlay: Control
var _result_title: Label
var _result_detail: Label


func on_pushed(_args: Dictionary = {}) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_hud()
	resized.connect(_layout_hud)
	call_deferred("_layout_hud")
	call_deferred("_initialize_round")


func set_bot_count(count: int) -> void:
	_bot_count = clampi(count, 0, 4)
	_update_opponents_label()
	if _round_initialized:
		_initialize_bots()
	queue_redraw()


func _initialize_round() -> void:
	if _round_initialized or size.x <= 0.0 or size.y <= 0.0:
		return

	_round_initialized = true
	_phase = Phase.COUNTDOWN
	_countdown_remaining = 3.0
	_countdown_banner_remaining = 0.0
	_elapsed = 0.0
	_capture_count = 0
	_kill_count = 0
	_drawing_trail = false
	_trail.clear()
	_player_direction = Vector2.RIGHT
	_gesture_direction = Vector2.ZERO
	_feedback_text = "Corte rastros ou feche uma volta"
	_feedback_remaining = 3.0

	var field := _field_rect()
	var claim_size := Vector2(240.0, 220.0)
	_claim_rect = Rect2(
		Vector2(field.position.x + 24.0, field.position.y + (field.size.y - claim_size.y) * 0.5),
		claim_size
	)
	_player_position = _claim_rect.get_center()
	_territory_percent = _claim_area_percent()
	_initialize_bots()
	_update_all_labels()
	_countdown_label.visible = true
	_countdown_label.text = "3"
	if is_instance_valid(_result_overlay):
		_result_overlay.hide()
	queue_redraw()


func _initialize_bots() -> void:
	_bot_positions.clear()
	_bot_directions.clear()
	_bot_trails.clear()
	_bot_home_rects.clear()
	_bot_alive.clear()
	_bot_outside.clear()
	_bot_flash.clear()

	var field := _field_rect()
	var home_size := Vector2(220.0, 184.0)
	var home_rects: Array[Rect2] = [
		Rect2(Vector2(field.end.x - home_size.x - 24.0, field.position.y + 82.0), home_size),
		Rect2(Vector2(field.end.x - home_size.x - 24.0, field.end.y - home_size.y - 82.0), home_size),
		Rect2(Vector2(field.position.x + field.size.x * 0.48, field.position.y + field.size.y * 0.43), home_size),
		Rect2(Vector2(field.position.x + field.size.x * 0.48, field.position.y + field.size.y * 0.10), home_size)
	]
	var directions: Array[Vector2] = [
		Vector2.LEFT,
		Vector2.UP,
		Vector2.RIGHT,
		Vector2.DOWN
	]

	for index in range(_bot_count):
		var home := home_rects[index % home_rects.size()]
		_bot_home_rects.append(home)
		_bot_positions.append(home.get_center())
		_bot_directions.append(directions[index % directions.size()])
		_bot_trails.append([])
		_bot_alive.append(true)
		_bot_outside.append(false)
		_bot_flash.append(0.0)

	_update_opponents_label()


func _process(delta: float) -> void:
	if not _round_initialized:
		_initialize_round()
		return

	for index in range(_bot_flash.size()):
		_bot_flash[index] = maxf(0.0, _bot_flash[index] - delta)

	if _feedback_remaining > 0.0:
		_feedback_remaining = maxf(0.0, _feedback_remaining - delta)

	match _phase:
		Phase.COUNTDOWN:
			_countdown_remaining = maxf(0.0, _countdown_remaining - delta)
			_countdown_label.visible = true
			_countdown_label.text = str(ceili(_countdown_remaining))
			if _countdown_remaining <= 0.0:
				_phase = Phase.PLAYING
				_countdown_label.text = "VAI!"
				_countdown_banner_remaining = 0.9
				_feedback_text = "Feche uma volta para dominar o campo"
				_feedback_remaining = 2.5
		Phase.PLAYING:
			_elapsed += delta
			if _countdown_label.visible:
				_countdown_banner_remaining = maxf(0.0, _countdown_banner_remaining - delta)
				if _countdown_banner_remaining <= 0.0:
					_countdown_label.visible = false
			_update_player(delta)
			_update_bots(delta)
			_resolve_combat()
			if _phase == Phase.PLAYING:
				_check_win()
		Phase.RESULT:
			pass

	_update_all_labels()
	queue_redraw()


func _update_player(delta: float) -> void:
	var input_direction := _read_direction()
	if input_direction.length_squared() > 0.01:
		_player_direction = input_direction.normalized()

	var movement_field := _field_rect().grow(-PLAYER_RADIUS)
	var next_position := _player_position + _player_direction * PLAYER_SPEED * delta
	next_position.x = clampf(next_position.x, movement_field.position.x, movement_field.end.x)
	next_position.y = clampf(next_position.y, movement_field.position.y, movement_field.end.y)

	var inside_claim := _claim_rect.grow(PLAYER_RADIUS * 0.7).has_point(next_position)
	if not _drawing_trail and not inside_claim:
		_drawing_trail = true
		_trail.clear()
		_trail.append(_player_position)

	if _drawing_trail:
		if _trail.is_empty() or _trail[_trail.size() - 1].distance_to(next_position) >= TRAIL_MIN_DISTANCE:
			_trail.append(next_position)
		if inside_claim and _trail.size() >= 3:
			_player_position = next_position
			_seal_trail()
			return

	_player_position = next_position


func _seal_trail() -> void:
	if _trail.size() < 3:
		_drawing_trail = false
		_trail.clear()
		return

	var trail_bounds := Rect2(_trail[0], Vector2.ZERO)
	for point in _trail:
		trail_bounds = trail_bounds.expand(point)

	var field := _field_rect()
	var expanded_bounds := trail_bounds.grow(PLAYER_RADIUS * 1.6)
	var new_claim := _claim_rect.merge(expanded_bounds).intersection(field)
	var old_area := _claim_rect.get_area()
	var new_area := new_claim.get_area()

	_drawing_trail = false
	_trail.clear()
	if new_area <= old_area:
		return

	_claim_rect = new_claim
	var gain := (new_area - old_area) / maxf(1.0, field.get_area()) * 100.0
	_territory_percent = _claim_area_percent()
	_capture_count += 1
	_feedback_text = "ÁREA CAPTURADA  +%.1f%%" % gain
	_feedback_remaining = 2.0

	for index in range(_bot_positions.size()):
		if _bot_alive[index] and _claim_rect.grow(BOT_RADIUS).has_point(_bot_positions[index]):
			_eliminate_bot(index, "ESMAGADO")

	_update_territory_label()
	if _phase == Phase.PLAYING and _territory_percent >= WIN_TERRITORY_PERCENT:
		_finish_match(true, "DOMINAÇÃO DO CAMPO")


func _update_bots(delta: float) -> void:
	var movement_field := _field_rect().grow(-BOT_RADIUS)
	for index in range(_bot_positions.size()):
		if not _bot_alive[index]:
			continue

		var previous_position := _bot_positions[index]
		var next_position := previous_position + _bot_directions[index] * BOT_SPEED * delta
		var next_direction := _bot_directions[index]

		if next_position.x <= movement_field.position.x or next_position.x >= movement_field.end.x:
			next_position.x = clampf(next_position.x, movement_field.position.x, movement_field.end.x)
			next_direction.x *= -1.0
		if next_position.y <= movement_field.position.y or next_position.y >= movement_field.end.y:
			next_position.y = clampf(next_position.y, movement_field.position.y, movement_field.end.y)
			next_direction.y *= -1.0

		_bot_positions[index] = next_position
		_bot_directions[index] = next_direction

		if not _bot_outside[index] and not _bot_home_rects[index].grow(BOT_RADIUS).has_point(next_position):
			_bot_outside[index] = true
			_bot_trails[index].clear()
			_bot_trails[index].append(previous_position)

		if _bot_outside[index]:
			var bot_trail: Array = _bot_trails[index]
			if bot_trail.is_empty() or bot_trail[bot_trail.size() - 1].distance_to(next_position) >= TRAIL_MIN_DISTANCE:
				bot_trail.append(next_position)
			while bot_trail.size() > BOT_TRAIL_MAX_POINTS:
				bot_trail.pop_front()


func _resolve_combat() -> void:
	for index in range(_bot_positions.size()):
		if not _bot_alive[index]:
			continue

		var bot_position := _bot_positions[index]
		var bot_trail: Array = _bot_trails[index]
		if _trail.size() > 1 and _polyline_hits_circle(_trail, bot_position, BOT_RADIUS + 12.0):
			_eliminate_bot(index, "CORTE DIRETO")
			continue
		if bot_trail.size() > 1 and _polyline_hits_circle(bot_trail, _player_position, PLAYER_RADIUS + 10.0):
			_eliminate_bot(index, "RASTRO CORTADO")
			continue
		if bot_position.distance_to(_player_position) <= PLAYER_RADIUS + BOT_RADIUS:
			_eliminate_bot(index, "IMPACTO")

	for index in range(_bot_positions.size()):
		if not _bot_alive[index]:
			continue
		for other in range(_bot_positions.size()):
			if index == other or not _bot_alive[other]:
				continue
			var other_trail: Array = _bot_trails[other]
			if other_trail.size() > 1 and _polyline_hits_circle(other_trail, _bot_positions[index], BOT_RADIUS + 8.0):
				_eliminate_bot(index, "DISPUTA")
				break


func _eliminate_bot(index: int, cause: String) -> void:
	if index < 0 or index >= _bot_alive.size() or not _bot_alive[index]:
		return

	_bot_alive[index] = false
	_bot_flash[index] = 0.75
	_bot_trails[index].clear()
	_kill_count += 1
	_feedback_text = "%s ELIMINADO  •  %s" % [_bot_names[index % _bot_names.size()], cause]
	_feedback_remaining = 2.2
	_update_all_labels()

	if _active_bot_count() == 0:
		_finish_match(true, "TODOS OS ADVERSÁRIOS ELIMINADOS")


func _check_win() -> void:
	if _active_bot_count() == 0:
		_finish_match(true, "TODOS OS ADVERSÁRIOS ELIMINADOS")
	elif _territory_percent >= WIN_TERRITORY_PERCENT:
		_finish_match(true, "DOMINAÇÃO DO CAMPO")


func _finish_match(won: bool, cause: String) -> void:
	if _phase == Phase.RESULT:
		return

	_phase = Phase.RESULT
	_drawing_trail = false
	_trail.clear()
	_countdown_label.visible = false
	_result_title.text = "VITÓRIA" if won else "FIM DE PARTIDA"
	_result_detail.text = "%s\n\n%d%% DO CAMPO\n%d ELIMINAÇÕES  •  %d CAPTURAS\nTEMPO  %s" % [
		cause,
		int(round(_territory_percent)),
		_kill_count,
		_capture_count,
		_format_time(_elapsed)
	]
	_result_overlay.show()
	match_finished.emit(won)


func _read_direction() -> Vector2:
	var keyboard_direction := Vector2.ZERO
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		keyboard_direction.x -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		keyboard_direction.x += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		keyboard_direction.y -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		keyboard_direction.y += 1.0

	if keyboard_direction.length_squared() > 0.01:
		return keyboard_direction.normalized()
	if _gesture_direction.length_squared() > 0.01:
		return _gesture_direction
	return _player_direction


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_direction := _direction_for_key(event.keycode)
		if key_direction.length_squared() > 0.01:
			_player_direction = key_direction
	elif event is InputEventScreenTouch:
		if event.pressed:
			_gesture_active = true
			_gesture_start = event.position
		else:
			_gesture_active = false
	elif event is InputEventScreenDrag and _gesture_active:
		_set_gesture_direction(event.position - _gesture_start)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse_active = event.pressed
		if event.pressed:
			_gesture_start = event.position
	elif event is InputEventMouseMotion and _mouse_active:
		_set_gesture_direction(event.position - _gesture_start)


func _set_gesture_direction(offset: Vector2) -> void:
	if offset.length() < 12.0:
		return
	_gesture_direction = offset.normalized()
	_player_direction = _gesture_direction


func _direction_for_key(keycode: int) -> Vector2:
	match keycode:
		KEY_LEFT, KEY_A:
			return Vector2.LEFT
		KEY_RIGHT, KEY_D:
			return Vector2.RIGHT
		KEY_UP, KEY_W:
			return Vector2.UP
		KEY_DOWN, KEY_S:
			return Vector2.DOWN
	return Vector2.ZERO


func _build_hud() -> void:
	var header_top := _hud_header_top()
	var elements := MatchHudBuilder.build_hud(self, header_top)
	_top_bar = elements["top_bar"]
	_territory_label = elements["territory_label"]
	_kills_label = elements["kills_label"]
	_opponents_label = elements["opponents_label"]
	_time_label = elements["time_label"]
	_status_label = elements["status_label"]
	_territory_bar = elements["territory_bar"]
	_countdown_label = elements["countdown_label"]
	_hint_label = elements["hint_label"]
	_actions = elements["actions"]
	(elements["exit_button"] as Button).pressed.connect(_on_exit_pressed)

	_build_result_overlay()


func _layout_hud() -> void:
	if not is_instance_valid(_top_bar):
		return

	var header_top := _hud_header_top()
	_top_bar.offset_top = header_top + 14.0
	_top_bar.offset_bottom = header_top + 112.0
	_status_label.offset_top = header_top + 130.0
	_status_label.offset_bottom = header_top + 176.0
	_territory_bar.offset_top = header_top + 186.0
	_territory_bar.offset_bottom = header_top + 216.0

	var field := _field_rect()
	_hint_label.offset_top = field.end.y + 58.0
	_hint_label.offset_bottom = field.end.y + 118.0

	var bottom_offset := maxf(92.0, _safe_bottom_inset() + 48.0)
	_actions.offset_bottom = -bottom_offset
	_actions.offset_top = -bottom_offset - 144.0
	queue_redraw()


func _build_result_overlay() -> void:
	var elements: Dictionary = {}
	MatchHudBuilder.build_result_overlay(self, elements)
	_result_overlay = elements["result_overlay"]
	_result_title = elements["result_title"]
	_result_detail = elements["result_detail"]
	(elements["restart_button"] as Button).pressed.connect(_on_restart_pressed)
	(elements["menu_button"] as Button).pressed.connect(_on_exit_pressed)


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var viewport_rect := Rect2(Vector2.ZERO, size)
	draw_rect(viewport_rect, Color("050b15"))

	for diagonal in range(-8, 18):
		var start := Vector2(float(diagonal) * 160.0, 0.0)
		draw_line(start, start + Vector2(-size.y * 0.42, size.y), Color(0.08, 0.20, 0.30, 0.18), 2.0)

	var header := Rect2(PANEL_MARGIN, 28.0, size.x - PANEL_MARGIN * 2.0, 190.0)
	draw_rect(header, Color("0a1726"))
	draw_rect(Rect2(header.position, Vector2(6.0, header.size.y)), Color("2dd4bf"))
	draw_line(
		Vector2(header.position.x + 28.0, header.end.y - 2.0),
		Vector2(header.end.x - 28.0, header.end.y - 2.0),
		Color("1d3d56"),
		2.0
	)

	var field := _field_rect()
	draw_rect(field.grow(24.0), Color(0.0, 0.0, 0.0, 0.26))
	draw_rect(field.grow(12.0), Color("0a1a29"))
	draw_rect(field, Color("091f2d"))
	draw_rect(field, Color("2dd4bf"), false, 3.0)

	for column in range(1, 12):
		var x := field.position.x + field.size.x * float(column) / 12.0
		draw_line(Vector2(x, field.position.y), Vector2(x, field.end.y), Color(0.15, 0.52, 0.58, 0.16), 1.0)
	for row in range(1, 13):
		var y := field.position.y + field.size.y * float(row) / 13.0
		draw_line(Vector2(field.position.x, y), Vector2(field.end.x, y), Color(0.15, 0.52, 0.58, 0.16), 1.0)

	_draw_field_brackets(field)

	for index in range(_bot_positions.size()):
		if not _bot_alive[index]:
			continue
		var home := _bot_home_rects[index]
		var bot_color := _bot_colors[index % _bot_colors.size()]
		draw_rect(home, Color(bot_color, 0.035))
		draw_rect(home, Color(bot_color, 0.28), false, 2.0)
		var bot_trail: Array = _bot_trails[index]
		if bot_trail.size() > 1:
			draw_polyline(PackedVector2Array(bot_trail), Color(0.0, 0.0, 0.0, 0.35), 18.0, true)
			draw_polyline(PackedVector2Array(bot_trail), Color(bot_color, 0.82), 8.0, true)
			draw_polyline(PackedVector2Array(bot_trail), Color(bot_color, 0.20), 22.0, true)

	if _round_initialized:
		draw_rect(_claim_rect.grow(8.0), Color("0b766f"), false, 8.0)
		draw_rect(_claim_rect, Color(0.12, 0.68, 0.60, 0.20))
		draw_rect(_claim_rect, Color("57e6d0"), false, 3.0)
		for stripe in range(-2, 8):
			var stripe_start := Vector2(_claim_rect.position.x + float(stripe) * 90.0, _claim_rect.end.y)
			var stripe_end := stripe_start + Vector2(220.0, -220.0)
			draw_line(stripe_start, stripe_end, Color(0.34, 0.95, 0.84, 0.12), 3.0)

	if _trail.size() > 1:
		draw_polyline(PackedVector2Array(_trail), Color(0.0, 0.0, 0.0, 0.42), 22.0, true)
		draw_polyline(PackedVector2Array(_trail), Color("f9c74f"), 11.0, true)
		draw_polyline(PackedVector2Array(_trail), Color("fff3b0"), 3.0, true)

	for index in range(_bot_positions.size()):
		var bot_color := _bot_colors[index % _bot_colors.size()]
		if _bot_alive[index]:
			_draw_bot(_bot_positions[index], bot_color, BOT_RADIUS, _bot_directions[index])
		elif _bot_flash[index] > 0.0:
			_draw_eliminated_bot(_bot_positions[index], bot_color, _bot_flash[index])

	if _round_initialized:
		var pulse := 4.0 + sin(_elapsed * 7.0) * 3.0
		draw_circle(_player_position, PLAYER_RADIUS + 16.0 + pulse, Color(0.98, 0.78, 0.31, 0.10))
		draw_circle(_player_position, PLAYER_RADIUS + 7.0, Color("f9c74f"), false, 3.0)
		draw_circle(_player_position, PLAYER_RADIUS, Color("f9c74f"))
		draw_line(
			_player_position,
			_player_position + _player_direction * 42.0,
			Color("fff3b0"),
			5.0,
			true
		)

	var footer := Rect2(PANEL_MARGIN, FIELD_BOTTOM + 58.0, size.x - PANEL_MARGIN * 2.0, 160.0)
	draw_rect(footer, Color("081521"))
	draw_line(
		Vector2(footer.position.x + 24.0, footer.position.y),
		Vector2(footer.end.x - 24.0, footer.position.y),
		Color("1d3d56"),
		2.0
	)


func _draw_field_brackets(field: Rect2) -> void:
	var length := 34.0
	var color := Color("65f4df")
	var left := field.position.x
	var right := field.end.x
	var top := field.position.y
	var bottom := field.end.y

	draw_line(Vector2(left, top + length), Vector2(left, top), color, 5.0)
	draw_line(Vector2(left, top), Vector2(left + length, top), color, 5.0)
	draw_line(Vector2(right - length, top), Vector2(right, top), color, 5.0)
	draw_line(Vector2(right, top), Vector2(right, top + length), color, 5.0)
	draw_line(Vector2(left, bottom - length), Vector2(left, bottom), color, 5.0)
	draw_line(Vector2(left, bottom), Vector2(left + length, bottom), color, 5.0)
	draw_line(Vector2(right - length, bottom), Vector2(right, bottom), color, 5.0)
	draw_line(Vector2(right, bottom - length), Vector2(right, bottom), color, 5.0)


func _draw_bot(position: Vector2, color: Color, radius: float, direction: Vector2) -> void:
	draw_circle(position, radius + 16.0, Color(color, 0.10))
	draw_circle(position, radius + 7.0, Color(color, 0.24), false, 3.0)
	draw_circle(position, radius, color)
	draw_line(position, position + direction * 32.0, Color("f4fbff"), 4.0, true)


func _draw_eliminated_bot(position: Vector2, color: Color, strength: float) -> void:
	var radius := BOT_RADIUS + (1.0 - strength) * 24.0
	draw_circle(position, radius, Color(color, strength * 0.16), false, 4.0)
	draw_line(
		position - Vector2(radius, radius),
		position + Vector2(radius, radius),
		Color("ff6b6b", strength),
		5.0,
		true
	)
	draw_line(
		position + Vector2(-radius, radius),
		position + Vector2(radius, -radius),
		Color("ff6b6b", strength),
		5.0,
		true
	)


func _polyline_hits_circle(points: Array, center: Vector2, radius: float) -> bool:
	if points.size() == 0:
		return false
	if points.size() == 1:
		return points[0].distance_to(center) <= radius

	for index in range(points.size() - 1):
		if _distance_to_segment(center, points[index], points[index + 1]) <= radius:
			return true
	return false


func _distance_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var length_squared := segment.length_squared()
	if length_squared <= 0.001:
		return point.distance_to(start)
	var ratio := clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_to(start + segment * ratio)


func _field_rect() -> Rect2:
	var top := minf(FIELD_TOP, size.y * 0.22)
	var bottom := minf(FIELD_BOTTOM, size.y - 350.0)
	return Rect2(
		Vector2(FIELD_MARGIN, top),
		Vector2(maxf(420.0, size.x - FIELD_MARGIN * 2.0), maxf(480.0, bottom - top))
	)


func _claim_area_percent() -> float:
	return _claim_rect.get_area() / maxf(1.0, _field_rect().get_area()) * 100.0


func _update_all_labels() -> void:
	_update_territory_label()
	_update_kills_label()
	_update_opponents_label()
	if is_instance_valid(_time_label):
		_time_label.text = _format_time(_elapsed)
	if is_instance_valid(_hint_label):
		_hint_label.text = _feedback_text if _feedback_remaining > 0.0 else "DESLIZE OU USE AS SETAS PARA VIRAR"
	if is_instance_valid(_territory_bar):
		_territory_bar.value = _territory_percent


func _update_territory_label() -> void:
	if is_instance_valid(_territory_label):
		_territory_label.text = "ÁREA %02d%%" % int(round(_territory_percent))


func _update_kills_label() -> void:
	if is_instance_valid(_kills_label):
		_kills_label.text = "KOs %d" % _kill_count


func _update_opponents_label() -> void:
	if is_instance_valid(_opponents_label):
		_opponents_label.text = "RIVAIS %d" % _active_bot_count()


func _active_bot_count() -> int:
	var active := 0
	for alive in _bot_alive:
		if alive:
			active += 1
	return active


func _format_time(seconds: float) -> String:
	var whole_seconds := int(seconds)
	return "%02d:%02d" % [whole_seconds / 60, whole_seconds % 60]


func _on_restart_pressed() -> void:
	restart_requested.emit()
	_round_number += 1
	_round_initialized = false
	_initialize_round()


func _on_exit_pressed() -> void:
	exit_requested.emit()


func handle_back_button() -> bool:
	exit_requested.emit()
	return true
