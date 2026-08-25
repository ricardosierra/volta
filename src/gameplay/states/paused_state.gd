class_name PausedState
extends State

var _tree: SceneTree

func _init(tree: SceneTree) -> void:
	_tree = tree

func enter() -> void:
	Log.info("Game", "Entered PAUSED state")
	if _tree:
		_tree.paused = true

func exit() -> void:
	if _tree:
		_tree.paused = false
