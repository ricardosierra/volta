class_name RemoteInterpolation
extends RefCounted

var snapshots: Array[Dictionary] = []
var buffer_time: float = 0.1 # 100ms

func push_snapshot(time: float, pos: Vector2) -> void:
	snapshots.append({"time": time, "pos": pos})
	if snapshots.size() > 10:
		snapshots.pop_front()

func get_interpolated_position(current_time: float) -> Vector2:
	var target := current_time - buffer_time
	
	if snapshots.size() < 2:
		return snapshots[0].pos if snapshots.size() > 0 else Vector2.ZERO
		
	for i in range(snapshots.size() - 1):
		var s1 := snapshots[i]
		var s2 := snapshots[i+1]
		if s1.time <= target and s2.time >= target:
			var t: float = (target - s1.time) / (s2.time - s1.time)
			return s1.pos.lerp(s2.pos, t)
			
	return snapshots[-1].pos
