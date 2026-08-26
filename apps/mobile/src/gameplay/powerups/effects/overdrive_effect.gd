class_name OverdriveEffect
extends PowerUpEffect

func _init(r_id: int).(r_id, 8.0) -> void:
	id = "overdrive"

func on_apply(stats: StatBlock) -> void:
	stats.speed_multiplier *= 1.5

func on_expire(stats: StatBlock) -> void:
	stats.speed_multiplier /= 1.5
