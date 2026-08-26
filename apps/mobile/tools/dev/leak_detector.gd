class_name LeakDetector
extends Node

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_dump_stats()

func _dump_stats() -> void:
	print("RSS: ", OS.get_static_memory_usage() / 1024 / 1024, " MB")
	print("Orphan Nodes: ", Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
