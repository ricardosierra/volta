class_name ArcRenderer
extends Line2D

func update_from_tracker(tracker: ArcTracker, space: GridSpace) -> void:
	clear_points()
	for idx in tracker._cells:
		var x := idx % tracker.grid.width
		var y := idx / tracker.grid.width
		add_point(space.cell_to_world_center(Vector2i(x, y)))
