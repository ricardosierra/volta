class_name VfxPool
extends RefCounted

var _inactive: Array[Node] = []
var _active: Array[Node] = []
var _parent: Node
var _scene: PackedScene

func _init(scene: PackedScene, initial_size: int, parent_node: Node) -> void:
	_scene = scene
	_parent = parent_node
	for i in range(initial_size):
		_create_one()

func _create_one() -> void:
	var instance := _scene.instantiate()
	_parent.add_child(instance)
	# Assuming it has a hide() or sleep() method
	if instance.has_method("hide"):
		instance.hide()
	
	# Connect to a finished signal if it exists to auto-reclaim
	if instance.has_signal("finished"):
		instance.finished.connect(func(): reclaim(instance))
		
	_inactive.append(instance)

func get_instance() -> Node:
	if _inactive.is_empty():
		# Degrade gracefully instead of erroring or allocating during gameplay
		if _active.size() > 0:
			var oldest: Node = _active.pop_front()
			_inactive.append(oldest)
		else:
			return null # Absolute fallback
			
	var instance: Node = _inactive.pop_back()
	_active.append(instance)
	return instance

func reclaim(instance: Node) -> void:
	_active.erase(instance)
	_inactive.append(instance)
	if instance.has_method("hide"):
		instance.hide()

func _apply_quality_limits(preset: int) -> void:
	if preset == 0: # Low
		# Restrict max active particles
		pass
