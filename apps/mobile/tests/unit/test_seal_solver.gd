extends GutTest

## Caracterização de SealSolver.solve() antes/depois da extração das funções internas
## (Regra 8 do CLAUDE.md — territory/seal_solver.gd:5 tinha 102 linhas). SealSolver é
## simulação pura (docs/architecture/overview.md §1): estes testes travam o comportamento
## exato para provar que a refatoração da Task 2 deste plano não mudou resultado nenhum.

var grid: TerritoryGrid


func before_each() -> void:
	grid = TerritoryGrid.new()
	grid.setup(10, 10, [])


func _ring_tracker(runner_id: int) -> ArcTracker:
	var tracker := ArcTracker.new(runner_id, grid)
	tracker.mark(Vector2i(1, 2), Vector2i(1, 3))
	tracker.mark(Vector2i(1, 3), Vector2i(3, 3))
	tracker.mark(Vector2i(3, 3), Vector2i(3, 1))
	tracker.mark(Vector2i(3, 1), Vector2i(2, 1))
	return tracker


func test_rectangle_capture_seals_interior_and_arc_cells() -> void:
	grid.seed_claim(0, 1, 1, 1) # claim em (1,1), fecha o canto do anel
	var tracker := _ring_tracker(0)

	var result := SealSolver.solve(0, grid, tracker)

	assert_eq(result.captured_cells.size(), 8, "7 células de arc + a célula interior (2,2)")
	assert_eq(result.bounding_box, Rect2i(0, 0, 5, 5))
	assert_true(result.stolen_from_owners.is_empty())
	assert_true(result.swallowed_arcs.is_empty())


func test_seal_steals_enemy_claim_inside_capture() -> void:
	grid.seed_claim(0, 1, 1, 1)
	grid.set_owner(2, 2, 1) # (2,2) é claim do runner 1 antes do Seal do runner 0
	var tracker := _ring_tracker(0)

	var result := SealSolver.solve(0, grid, tracker)

	assert_eq(result.captured_cells.size(), 8)
	assert_eq(result.stolen_from_owners.get(1, 0), 1, "capturar (2,2) deveria roubar 1 célula do runner 1")


func test_seal_records_swallowed_enemy_arc() -> void:
	grid.seed_claim(0, 1, 1, 1)
	var tracker := _ring_tracker(0)
	var enemy_tracker := ArcTracker.new(2, grid)
	enemy_tracker.mark(Vector2i(2, 2), Vector2i(2, 2)) # arc de 1 célula do runner 2 dentro do anel

	var result := SealSolver.solve(0, grid, tracker)

	assert_eq(result.captured_cells.size(), 8)
	assert_true(result.swallowed_arcs.has(2), "o arc do runner 2 em (2,2) deveria ser engolido")


func test_seal_with_empty_arc_returns_empty_result() -> void:
	var empty_tracker := ArcTracker.new(0, grid)

	var result := SealSolver.solve(0, grid, empty_tracker)

	assert_true(result.captured_cells.is_empty())
	assert_eq(result.bounding_box, Rect2i())
