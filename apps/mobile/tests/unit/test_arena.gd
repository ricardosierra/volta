extends GutTest

## Arena + ArenaDefinition (MOVE-008, docs/design/balance.md §1). Prova que a dimensão vem
## de dado (não hardcoded), que get_pixel_size() bate com o open_field.tres corrigido, que
## as 4 arenas da Fase 13 continuam carregando com os defaults, e que a contenção nos
## limites desliza em vez de travar.

func _open_field() -> ArenaDefinition:
	return load("res://resources/arenas/open_field.tres") as ArenaDefinition

func test_open_field_resource_has_2048x2048_pixel_size() -> void:
	var def := _open_field()
	assert_eq(def.get_pixel_size(), Vector2(2048.0, 2048.0))

func test_open_field_is_valid_with_a_spawn_point() -> void:
	assert_true(_open_field().is_valid())

func test_definition_without_spawn_points_is_invalid() -> void:
	var def := ArenaDefinition.new()
	def.spawn_points = []
	assert_false(def.is_valid())

func test_arena_limits_match_definition_pixel_size() -> void:
	var arena := Arena.new(_open_field())
	assert_eq(arena.limits, Rect2(Vector2.ZERO, Vector2(2048.0, 2048.0)))

func test_phase_13_arenas_still_load_and_produce_valid_arena_limits() -> void:
	for path in [
		"res://resources/arenas/archipelago.tres",
		"res://resources/arenas/crossroads.tres",
		"res://resources/arenas/halo.tres",
		"res://resources/arenas/rift.tres",
	]:
		var def := load(path) as ArenaDefinition
		assert_not_null(def, "%s deveria carregar" % path)
		var arena := Arena.new(def)
		assert_eq(arena.limits.size, Vector2(2048.0, 2048.0), "%s deveria usar os defaults 128x128@16 (nenhum campo de dimensão seta valor próprio)" % path)

func test_runner_at_max_speed_never_leaves_the_arena() -> void:
	var arena := Arena.new(_open_field())
	var state := RunnerState.new()
	state.position = Vector2(2040.0, 2040.0)
	state.velocity = Vector2(999999.0, 999999.0) # empurra bem além da borda antes de conter

	arena.resolve_boundaries(state)

	assert_lte(state.position.x, arena.limits.end.x)
	assert_lte(state.position.y, arena.limits.end.y)

func test_runner_sliding_at_boundary_does_not_zero_the_tangential_velocity() -> void:
	var arena := Arena.new(_open_field())
	var state := RunnerState.new()
	state.position = Vector2(-5.0, 1000.0) # já passou da borda esquerda
	state.velocity = Vector2(-50.0, 80.0)

	arena.resolve_boundaries(state)

	assert_eq(state.position.x, arena.limits.position.x, "eixo perpendicular à borda deveria ser preso na borda")
	assert_eq(state.velocity.y, 80.0, "eixo tangente à borda não deveria ser afetado — é o deslize, não a trava")
