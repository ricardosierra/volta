class_name CameraReactions
extends Camera2D

var _shake_trauma: float = 0.0
var _shake_power: float = 2.0
var _shake_decay: float = 0.8
var accessibility: AccessibilitySettings

func _process(delta: float) -> void:
	if _shake_trauma > 0.0:
		_shake_trauma = max(_shake_trauma - _shake_decay * delta, 0.0)
		_apply_shake()

func _apply_shake() -> void:
	if accessibility and accessibility.reduce_shake > 0.0:
		var multiplier := 1.0 - accessibility.reduce_shake
		var amount := pow(_shake_trauma, _shake_power) * 30.0 * multiplier
		offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
	else:
		offset = Vector2.ZERO

func add_trauma(amount: float) -> void:
	_shake_trauma = min(_shake_trauma + amount, 1.0)

func on_seal(area: int) -> void:
	add_trauma(clamp(area / 200.0, 0.1, 0.6))
	if area >= 200:
		# Mega Seal: Slight slow-mo
		Engine.time_scale = 0.5
		var t := create_tween()
		t.tween_interval(0.12)
		t.tween_callback(func(): Engine.time_scale = 1.0)

func on_break() -> void:
	add_trauma(0.8)
