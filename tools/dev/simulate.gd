extends SceneTree

func _init() -> void:
	print("Running headless simulation invariants check...")
	var grid = TerritoryGrid.new()
	grid.setup(100, 100)
	grid.seed_claim(0, 50, 50, 4)
	
	# Simulating some seals
	var tracker = ArcTracker.new(0, grid)
	tracker.mark(Vector2i(50, 52), Vector2i(50, 60))
	tracker.mark(Vector2i(50, 60), Vector2i(60, 60))
	tracker.mark(Vector2i(60, 60), Vector2i(60, 50))
	tracker.mark(Vector2i(60, 50), Vector2i(52, 50))
	
	var result = SealSolver.solve(0, grid, tracker)
	var applier = SealApplier.new()
	applier.apply(result, grid, tracker)
	
	print("Captured cells: ", result.captured_cells.size())
	assert(result.captured_cells.size() > 0)
	
	print("Simulation OK.")
	quit()
