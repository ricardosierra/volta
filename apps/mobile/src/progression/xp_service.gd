class_name XpService
extends Node

const XP_MULT = 100.0
const XP_EXPONENT = 1.35

func calculate_level(xp: int) -> int:
	# xp = 100 * (lvl ^ 1.35)
	# lvl = (xp / 100) ^ (1 / 1.35)
	if xp <= 0: return 1
	var lvl = pow(float(xp) / XP_MULT, 1.0 / XP_EXPONENT)
	return max(1, int(floor(lvl)))

func xp_for_level(lvl: int) -> int:
	return int(XP_MULT * pow(float(lvl), XP_EXPONENT))

func add_xp(profile: Profile, amount: int) -> void:
	var old_lvl = calculate_level(profile.xp)
	profile.xp += amount
	var new_lvl = calculate_level(profile.xp)
	if new_lvl > old_lvl:
		_on_level_up(new_lvl)

func _on_level_up(new_lvl: int) -> void:
	# Emit particles, unlock frames
	pass
