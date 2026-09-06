class_name BonusDetector
extends Node

signal bonus_awarded(runner_id: int, bonus_name: String, points: int)

var config: Resource
var _recent_seals: Dictionary = {}

func _init(cfg: Resource) -> void:
	config = cfg

func on_seal(runner_id: int, cells_size: int, stolen: Dictionary) -> void:
	# Detect Mega Seal
	var threshold: int = config.get_meta("mega_seal_threshold", 200)
	if cells_size >= threshold:
		bonus_awarded.emit(runner_id, "MEGA SEAL", config.get_meta("mega_seal", 2000))
		
	# Combo seals (Double, Triple)
	var time := Time.get_ticks_msec()
	if not _recent_seals.has(runner_id):
		_recent_seals[runner_id] = []
	_recent_seals[runner_id].append(time)
	
	# Clean old
	var valid := []
	for t in _recent_seals[runner_id]:
		if time - t < 3000: # 3 sec window
			valid.append(t)
	_recent_seals[runner_id] = valid
	
	if valid.size() == 2:
		bonus_awarded.emit(runner_id, "DOUBLE SEAL", config.get_meta("double_seal", 500))
	elif valid.size() == 3:
		bonus_awarded.emit(runner_id, "TRIPLE SEAL", config.get_meta("triple_seal", 1500))

func on_squeeze(killer: int) -> void:
	bonus_awarded.emit(killer, "SQUEEZE", config.get_meta("squeeze", 1000))
