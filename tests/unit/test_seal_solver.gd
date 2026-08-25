extends "res://addons/gut/test.gd"

var grid: TerritoryGrid
var tracker: ArcTracker

func before_each():
	grid = TerritoryGrid.new()
	grid.setup(10, 10, [])
	tracker = ArcTracker.new(0, grid)

func test_rectangle_capture():
	grid.seed_claim(0, 1, 1, 1) # claim at (1,1)
	
	# Draw arc around (2,2)
	tracker.mark(Vector2i(1,2), Vector2i(1,3))
	tracker.mark(Vector2i(1,3), Vector2i(3,3))
	tracker.mark(Vector2i(3,3), Vector2i(3,1))
	tracker.mark(Vector2i(3,1), Vector2i(2,1))
	
	var res = SealSolver.solve(0, grid, tracker)
	
	# Should have captured the inside (2,2) plus the arc cells (7 cells)
	assert_eq(res.captured_cells.size(), 8)
