class_name RunnerMark
extends RefCounted

## Marca geométrica no núcleo de cada Runner. Existe porque nenhum elemento crítico pode
## depender só de cor (docs/ui/design-system.md §5.4 e docs/ui/accessibility.md): num tema
## daltônico duas cores de Runner podem colidir, a forma nunca.

enum Shape {
	CIRCLE,
	TRIANGLE,
	SQUARE,
	DIAMOND,
	HEXAGON,
	CROSS,
	PENTAGON,
	STAR
}

const ORDER: Array[Shape] = [
	Shape.CIRCLE,
	Shape.TRIANGLE,
	Shape.SQUARE,
	Shape.DIAMOND,
	Shape.HEXAGON,
	Shape.CROSS,
	Shape.PENTAGON,
	Shape.STAR
]


static func for_runner(runner_id: int) -> Shape:
	if runner_id < 0:
		return Shape.CIRCLE
	return ORDER[runner_id % ORDER.size()]


## Vértices da marca, normalizados num círculo de raio 1 centrado na origem.
static func points(shape: Shape) -> PackedVector2Array:
	match shape:
		Shape.TRIANGLE:
			return _regular(3, -PI * 0.5)
		Shape.SQUARE:
			return _regular(4, PI * 0.25)
		Shape.DIAMOND:
			return _regular(4, -PI * 0.5)
		Shape.HEXAGON:
			return _regular(6, -PI * 0.5)
		Shape.PENTAGON:
			return _regular(5, -PI * 0.5)
		Shape.CROSS:
			return _cross()
		Shape.STAR:
			return _star()
		_:
			return _regular(16, 0.0)


static func _regular(sides: int, phase: float) -> PackedVector2Array:
	var result := PackedVector2Array()
	for i in range(sides):
		var angle: float = phase + TAU * float(i) / float(sides)
		result.append(Vector2(cos(angle), sin(angle)))
	return result


static func _cross() -> PackedVector2Array:
	var arm: float = 0.38
	var tip: float = 1.0
	return PackedVector2Array([
		Vector2(-arm, -tip), Vector2(arm, -tip), Vector2(arm, -arm),
		Vector2(tip, -arm), Vector2(tip, arm), Vector2(arm, arm),
		Vector2(arm, tip), Vector2(-arm, tip), Vector2(-arm, arm),
		Vector2(-tip, arm), Vector2(-tip, -arm), Vector2(-arm, -arm)
	])


static func _star() -> PackedVector2Array:
	var result := PackedVector2Array()
	for i in range(10):
		var radius: float = 1.0 if i % 2 == 0 else 0.46
		var angle: float = -PI * 0.5 + TAU * float(i) / 10.0
		result.append(Vector2(cos(angle), sin(angle)) * radius)
	return result
