class_name MatchScreen
extends Screen

signal restart_requested
signal match_finished(won: bool)

const FIELD_MARGIN: float = 72.0
const FIELD_TOP: float = 260.0
const FIELD_BOTTOM: float = 1470.0
const PANEL_MARGIN: float = 48.0
const MIN_TOUCH_TARGET_HEIGHT: float = 136.0

var _match_director: MatchDirector
var _input_router: InputRouter
var _bot_count: int = 0
var _countdown_display: float = 3.0

var _opponents_label: Label
var _time_label: Label
var _status_label: Label
var _countdown_label: Label
var _hint_label: Label
var _top_bar: HBoxContainer
var _actions: CenterContainer


func _init() -> void:
	# Nao consumir toque e propriedade da tela, nao do fato de ela ter sido empilhada:
	# a MatchScreen cobre a arena inteira e o InputRouter escuta _unhandled_input
	# (GSD 02, Plano 02-07).
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func on_pushed(_args: Dictionary = {}) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_hud()
	resized.connect(_layout_hud)
	call_deferred("_layout_hud")


func set_bot_count(count: int) -> void:
	_bot_count = clampi(count, 0, 4)
	_update_opponents_label()


func set_match_director(director: MatchDirector) -> void:
	_match_director = director


func set_input_router(router: InputRouter) -> void:
	_input_router = router


func _process(delta: float) -> void:
	if not _match_director or not _match_director.game_state:
		return

	var current := _match_director.game_state.current_state()
	if current == GameState.Id.COUNTDOWN:
		_countdown_display = maxf(0.0, _countdown_display - delta)
		_countdown_label.visible = true
		_countdown_label.text = str(ceili(_countdown_display)) if _countdown_display > 0.0 else "VAI!"
	else:
		_countdown_display = 3.0
		_countdown_label.visible = false

	_update_all_labels()


func _draw() -> void:
	MatchFieldRenderer.draw(self, {
		"size": size,
		"field": _field_rect(),
	})


func _build_hud() -> void:
	var header_top := _hud_header_top()
	var elements := MatchHudBuilder.build_hud(self, header_top)
	_top_bar = elements["top_bar"]
	_opponents_label = elements["opponents_label"]
	_time_label = elements["time_label"]
	_status_label = elements["status_label"]
	_countdown_label = elements["countdown_label"]
	_hint_label = elements["hint_label"]
	_actions = elements["actions"]
	(elements["pause_button"] as Button).pressed.connect(_on_pause_pressed)
	(elements["settings_button"] as Button).pressed.connect(_on_settings_pressed)
	(elements["exit_button"] as Button).pressed.connect(_on_exit_pressed)


func _layout_hud() -> void:
	if not is_instance_valid(_top_bar):
		return

	var header_top := _hud_header_top()
	_top_bar.offset_top = header_top + 14.0
	_top_bar.offset_bottom = header_top + 112.0
	_status_label.offset_top = header_top + 130.0
	_status_label.offset_bottom = header_top + 176.0

	var field := _field_rect()
	_hint_label.offset_top = field.end.y + 58.0
	_hint_label.offset_bottom = field.end.y + 118.0

	var bottom_offset := maxf(92.0, _safe_bottom_inset() + 48.0)
	_actions.offset_bottom = -bottom_offset
	_actions.offset_top = -bottom_offset - 144.0


## Safe area do topo (notch/status bar), em pixels. Mesmo padrão de
## ui/components/safe_area_container.gd — headless/editor sem safe area reportada cai em 0.
func _hud_header_top() -> float:
	var safe_area := DisplayServer.get_display_safe_area()
	if safe_area.size.y > 0:
		return float(safe_area.position.y)
	return 0.0


## Safe area de baixo (gesture bar/home indicator), em pixels.
func _safe_bottom_inset() -> float:
	var safe_area := DisplayServer.get_display_safe_area()
	var window_size := DisplayServer.window_get_size()
	if safe_area.size.y > 0:
		return float(window_size.y - (safe_area.position.y + safe_area.size.y))
	return 0.0


func _on_pause_pressed() -> void:
	if not _match_director or not _match_director.game_state:
		return
	_match_director.game_state.request_transition(GameState.Id.PAUSED)

	var pause := PauseScreen.new()
	pause.resume_requested.connect(_on_pause_resume_requested)
	pause.quit_requested.connect(_on_pause_quit_requested)
	(get_parent() as ScreenStack).push(pause)


func _on_pause_resume_requested() -> void:
	_match_director.game_state.request_transition(GameState.Id.PLAYING)
	(get_parent() as ScreenStack).pop()


func _on_pause_quit_requested() -> void:
	(get_parent() as ScreenStack).pop()
	_match_director.game_state.request_transition(GameState.Id.RESULTS)

	var results := ResultsScreen.new()
	results.menu_requested.connect(_on_results_menu_requested)
	# Fase 2 não tem restart real (MTC-04 é Fase 6) — os dois botões voltam ao menu, ver BACKLOG BL-021.
	results.play_again_requested.connect(_on_results_menu_requested)
	(get_parent() as ScreenStack).push(results)


func _on_results_menu_requested() -> void:
	(get_parent() as ScreenStack).pop()
	exit_requested.emit()


func _on_settings_pressed() -> void:
	var settings := SettingsControls.new()
	if _input_router:
		settings.driver_changed.connect(_input_router.set_driver)
	settings.exit_requested.connect(func(): (get_parent() as ScreenStack).pop())
	(get_parent() as ScreenStack).push(settings)


## Área útil de jogo em pixels de tela, medida da HUD real desta tela. A GameCamera enquadra
## a partir daqui em vez de usar a viewport inteira — se a HUD mudar, o enquadramento muda
## junto (regra de enquadramento do Jogos/CLAUDE.md).
func play_area_rect() -> Rect2:
	return _field_rect()


func _field_rect() -> Rect2:
	var top := minf(FIELD_TOP, size.y * 0.22)
	var bottom := minf(FIELD_BOTTOM, size.y - 350.0)
	return Rect2(
		Vector2(FIELD_MARGIN, top),
		Vector2(maxf(420.0, size.x - FIELD_MARGIN * 2.0), maxf(480.0, bottom - top))
	)


func _update_all_labels() -> void:
	_update_opponents_label()
	if is_instance_valid(_time_label):
		_time_label.text = _format_time(_match_director.time_elapsed if _match_director else 0.0)
	if is_instance_valid(_hint_label):
		_hint_label.text = "DESLIZE OU USE AS SETAS PARA VIRAR"


func _update_opponents_label() -> void:
	if not is_instance_valid(_opponents_label):
		return
	var active := (_match_director.runners.size() - 1) if _match_director else _bot_count
	_opponents_label.text = "RIVAIS %d" % maxi(0, active)


func _format_time(seconds: float) -> String:
	var whole_seconds := int(seconds)
	return "%02d:%02d" % [whole_seconds / 60, whole_seconds % 60]


func _on_exit_pressed() -> void:
	exit_requested.emit()


func handle_back_button() -> bool:
	exit_requested.emit()
	return true
