class_name BulwarkEffect
extends PowerUpEffect

func _init(r_id: int) -> void:
	# Sintaxe de Godot 3 (`func _init(r_id).(r_id, 15.0)`) nao compila no 4 — chamada da
	# base agora e super(). O arquivo nunca compilou desde a Fase 14 (771e0b0), e o
	# loader do Godot 4.7 chega a abortar ao carrega-lo (GSD 02, Plano 02-07).
	super(r_id, 15.0)
	id = "bulwark"

func on_apply(stats: StatBlock) -> void:
	stats.set_meta("has_bulwark", true)

func on_expire(stats: StatBlock) -> void:
	stats.remove_meta("has_bulwark")
