class_name BulwarkEffect
extends PowerUpEffect

func _init(r_id: int).(r_id, 15.0) -> void:
	id = "bulwark"

func on_apply(stats: StatBlock) -> void:
	stats.set_meta("has_bulwark", true)

func on_expire(stats: StatBlock) -> void:
	stats.remove_meta("has_bulwark")
