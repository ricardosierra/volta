class_name InputBuffer
extends RefCounted

class Command:
	var dir: Vector2
	var age: float
	
	func _init(d: Vector2) -> void:
		dir = d
		age = 0.0

var _queue: Array[Command] = []
var max_age: float = 0.5
var similarity_threshold: float = 0.95 # dot product threshold to discard similar commands

func push_command(dir: Vector2) -> void:
	if dir.length_squared() < 0.1:
		return
		
	dir = dir.normalized()
	
	if _queue.size() > 0:
		var last_cmd := _queue[_queue.size() - 1]
		if last_cmd.dir.dot(dir) > similarity_threshold:
			# Too similar, don't queue
			return
			
	_queue.append(Command.new(dir))

func tick(delta: float) -> void:
	# Age out old commands
	for i in range(_queue.size() - 1, -1, -1):
		_queue[i].age += delta
		if _queue[i].age > max_age:
			_queue.remove_at(i)

func has_commands() -> bool:
	return _queue.size() > 0

func pop_command() -> Vector2:
	if _queue.size() > 0:
		var cmd: Command = _queue.pop_front()
		return cmd.dir
	return Vector2.ZERO

func peek_command() -> Vector2:
	if _queue.size() > 0:
		return _queue[0].dir
	return Vector2.ZERO
