class_name InputRouter
extends Node

## Única porta de saída de direção para a simulação (docs/gameplay/controls.md,
## ADR-0014). Nenhum InputEvent chega ao Runner: eventos são coletados por
## _unhandled_input() (para não competir com toque em UI), traduzidos pelo driver ativo em
## um Vector2, e enfileirados num InputBuffer — a simulação só lê poll_direction() uma vez
## por tick de 60 Hz.

var driver: InputDriver
var buffer: InputBuffer

# Última direção efetivamente enfileirada (ou o valor inicial do driver). Evita empurrar
# no buffer eventos que não mudam a direção de fato (ex.: o toque inicial, antes de
# qualquer arraste, ou o toque solto) — sem isso, o primeiro poll_direction() consumiria
# um comando "fantasma" antes do comando real do arraste, atrasando a resposta em um tick.
var _last_pushed_direction: Vector2

func _init() -> void:
	driver = SwipeDriver.new()
	buffer = InputBuffer.new()
	_last_pushed_direction = driver.poll(0.0)

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if driver and driver.has_method("process_event"):
		driver.process_event(event)
		var direction := driver.poll(0.0)
		if direction.dot(_last_pushed_direction) <= buffer.similarity_threshold:
			buffer.push_command(direction)
			_last_pushed_direction = direction

	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var vp := get_viewport()
		if vp:
			vp.set_input_as_handled()

func poll_direction(delta: float) -> Vector2:
	buffer.tick(delta)
	if buffer.has_commands():
		return buffer.pop_command()
	if driver:
		return driver.poll(delta)
	return Vector2.ZERO

func set_driver(new_driver: InputDriver) -> void:
	driver = new_driver
	buffer = InputBuffer.new()
	_last_pushed_direction = driver.poll(0.0)
