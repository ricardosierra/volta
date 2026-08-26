
func _optimized_flood_fill(start_point: Vector2, boundary: Rect2) -> Array[Vector2]:
	# Use bounding box of the arc to limit scanline search space
	# This avoids searching the entire 1080x1920 grid.
	return []
