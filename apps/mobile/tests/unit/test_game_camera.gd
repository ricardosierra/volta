extends GutTest

## GameCamera (MOVE-009, docs/design/balance.md §11). Prova que setup() aplica os valores
## reais de CameraBalance, que o follow converge para a posição alvo (com lookahead), e que
## a câmera nunca mostra além da borda da Arena.
##
## As arenas de teste usam dimensões bem maiores que a viewport real do runner headless do
## GUT (1920x1920, medida em tempo de execução) — do contrário a metade da viewport (a
## "half_size" que o clamp de arena precisa subtrair) é maior que a própria arena, e nenhuma
## posição de câmera evitaria mostrar além da borda (ver _clamp_to_arena_axis em game_camera.gd).

func _small_arena() -> Arena:
	var def := ArenaDefinition.new()
	def.width_cells = 20
	def.height_cells = 20
	def.cell_size = 16.0 # 320x320
	def.spawn_points = [Vector2(160, 160)]
	return Arena.new(def)

func _big_arena() -> Arena:
	var def := ArenaDefinition.new()
	def.width_cells = 250
	def.height_cells = 250
	def.cell_size = 16.0 # 4000x4000 — bem maior que a viewport de teste (1920x1920)
	def.spawn_points = [Vector2(2000, 2000)]
	return Arena.new(def)

func test_setup_applies_camera_balance_values() -> void:
	var camera := GameCamera.new()
	add_child_autofree(camera)
	var balance := CameraBalance.new()
	balance.follow_smoothing = 12.0
	balance.lookahead = 55.0
	balance.zoom_base = 1.25

	camera.setup(balance, _small_arena())

	assert_eq(camera._follow_smoothing, 12.0)
	assert_eq(camera._lookahead_distance, 55.0)
	assert_eq(camera.zoom, Vector2(1.25, 1.25))

func test_camera_converges_toward_target_over_several_frames() -> void:
	var camera := GameCamera.new()
	add_child_autofree(camera)
	var arena := _big_arena()
	var balance := CameraBalance.new()
	camera.setup(balance, arena)

	var center := arena.limits.get_center()
	camera.global_position = center

	var target := InterpolatedVisual.new()
	add_child_autofree(target)
	target.global_position = center + Vector2(200.0, 0.0)
	camera.target_visual = target

	# Posição real para a qual a câmera converge: alvo + lookahead, longe de qualquer
	# borda da arena (sem interferência do clamp), igual ao cálculo de _process().
	var desired := target.global_position + Vector2.RIGHT * balance.lookahead
	var start_distance := camera.global_position.distance_to(desired)
	for i in range(30):
		camera._process(1.0 / 60.0)
	var end_distance := camera.global_position.distance_to(desired)

	assert_lt(end_distance, start_distance, "câmera deveria se aproximar da posição alvo (com lookahead) ao longo de vários frames")

func test_camera_never_shows_beyond_arena_edge() -> void:
	var camera := GameCamera.new()
	add_child_autofree(camera)
	var arena := _big_arena()
	camera.setup(CameraBalance.new(), arena)

	var target := InterpolatedVisual.new()
	add_child_autofree(target)
	target.global_position = Vector2(5, 5) # canto, bem perto da borda
	target.update_simulation_state(Vector2(5, 5), 0.0)
	camera.target_visual = target

	for i in range(120):
		camera._process(1.0 / 60.0)

	var half_size := camera.get_viewport_rect().size / 2.0 / camera.zoom
	assert_gte(camera.global_position.x, arena.limits.position.x + half_size.x - 0.5)
	assert_gte(camera.global_position.y, arena.limits.position.y + half_size.y - 0.5)

func test_process_without_target_or_arena_does_not_crash() -> void:
	var camera := GameCamera.new()
	add_child_autofree(camera)
	camera._process(0.016) # nem target_visual nem arena setados
	assert_null(camera.target_visual)
