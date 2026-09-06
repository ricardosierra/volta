class_name OverdriveEffect
extends PowerUpEffect

func _init(r_id: int) -> void:
	# Sintaxe de Godot 3 (`func _init(r_id).(r_id, 8.0)`) nao compila no 4 — chamada da
	# base agora e super(). O arquivo nunca compilou desde a Fase 14 (771e0b0), e o
	# loader do Godot 4.7 chega a abortar ao carrega-lo (GSD 02, Plano 02-07).
	super(r_id, 8.0)
	id = "overdrive"

func on_apply(stats: StatBlock) -> void:
	stats.speed_multiplier *= 1.5

func on_expire(stats: StatBlock) -> void:
	stats.speed_multiplier /= 1.5
