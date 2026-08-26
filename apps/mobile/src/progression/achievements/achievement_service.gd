class_name AchievementService
extends Node

var unlocked_ids: Array[String] = []

signal achievement_unlocked(ach: Achievement)

func check_stats(stats: StatsService, all_achievements: Array[Achievement]) -> void:
	for ach in all_achievements:
		if ach.id in unlocked_ids:
			continue
			
		var unlocked = false
		match ach.id:
			"first_blood": unlocked = stats.total_kills > 0
			"centurion": unlocked = stats.total_matches >= 100
			"dominator": unlocked = stats.total_wins >= 10
			
		if unlocked:
			unlocked_ids.append(ach.id)
			achievement_unlocked.emit(ach)
