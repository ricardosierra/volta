class_name ArcRasterizer
extends RefCounted

## Returns an array of 4-connected Vector2i cells forming a line between start and end.
static func supercover_line(p0: Vector2i, p1: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	points.append(p0)
	
	if p0 == p1:
		return points
		
	var dx = p1.x - p0.x
	var dy = p1.y - p0.y
	
	var step_x = 1 if dx > 0 else -1
	var step_y = 1 if dy > 0 else -1
	
	dx = abs(dx)
	dy = abs(dy)
	
	var x = p0.x
	var y = p0.y
	
	var err = dx - dy
	var err_x = err
	
	while x != p1.x or y != p1.y:
		var e2 = 2 * err
		
		var moved_x = false
		var moved_y = false
		
		if e2 > -dy:
			err -= dy
			x += step_x
			moved_x = true
			
		if e2 < dx:
			err += dx
			y += step_y
			moved_y = true
			
		# If diagonal movement, add orthogonal to make 4-connected
		if moved_x and moved_y:
			points.append(Vector2i(x - step_x, y))
			
		points.append(Vector2i(x, y))
		
	return points
