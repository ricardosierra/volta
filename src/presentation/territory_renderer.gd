class_name TerritoryRenderer
extends Sprite2D

var grid: TerritoryGrid
var image: Image
var tex: ImageTexture

func setup(g: TerritoryGrid) -> void:
	grid = g
	image = Image.create(grid.width, grid.height, false, Image.FORMAT_L8)
	image.fill(Color(254.0/255.0, 0, 0)) # Neutral
	tex = ImageTexture.create_from_image(image)
	texture = tex

func update_dirty_rect(rect: Rect2i) -> void:
	# Convert owner bytes to image grayscale
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var owner_id = grid.owner_of(x, y)
			image.set_pixel(x, y, Color(owner_id/255.0, 0, 0, 1.0))
			
	tex.update(image)
