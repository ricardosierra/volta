class_name PowerUpEffect
extends RefCounted

var id: String
var runner_id: int
var duration: float
var elapsed: float = 0.0

func _init(r_id: int, dur: float) -> void:
	runner_id = r_id
	duration = dur

func on_apply(stats: StatBlock) -> void:
	pass

func on_tick(delta: float, stats: StatBlock) -> void:
	elapsed += delta

func on_expire(stats: StatBlock) -> void:
	pass

func is_expired() -> bool:
	return duration > 0 and elapsed >= duration
