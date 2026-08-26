class_name InputValidator
extends RefCounted

var last_tick: int = 0

func is_valid(msg: Dictionary) -> bool:
	if not msg.has("tick") or not msg.has("dir"):
		return false
		
	if msg.tick <= last_tick:
		return false # Out of order
		
	last_tick = msg.tick
	
	if typeof(msg.dir) != TYPE_VECTOR2:
		return false
		
	if msg.dir.length_squared() > 1.01: # Allow some float imprecision
		return false
		
	return true
