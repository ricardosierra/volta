extends "res://addons/gut/test.gd"

var grid: TerritoryGrid

func before_each():
	grid = TerritoryGrid.new()
	grid.setup(10, 10, [])

func test_seed_claim_counts_correctly():
	grid.seed_claim(0, 5, 5, 2)
	assert_eq(grid._claim_count[0], 4, "Should have 4 cells claimed")

func test_release_claim_resets_count():
	grid.seed_claim(1, 2, 2, 2)
	assert_eq(grid._claim_count[1], 4)
	grid.release_claim(1)
	assert_eq(grid._claim_count[1], 0, "Claim count should be zeroed")
	assert_eq(grid.owner_of(2, 2), 254, "Cell should be neutral")
