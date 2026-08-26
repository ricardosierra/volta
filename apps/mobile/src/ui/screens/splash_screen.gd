class_name SplashScreen
extends Screen

func on_pushed(args: Dictionary = {}) -> void:
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(_on_splash_done)

func _on_splash_done() -> void:
	# Navigation to Main Menu
	pass
