class_name LeaderboardScreen
extends Screen

# 6 tabs: Daily, Weekly, Monthly, All-Time, Friends, Country

func on_pushed(args: Dictionary = {}) -> void:
	# Build UI
	var label := Label.new()
	label.text = "Leaderboards (Offline/Loading)"
	add_child(label)
