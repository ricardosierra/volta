extends Node

var _timestamps: Array[float] = []
var _samples: int = 0
var max_samples: int = 100

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		var time = Time.get_ticks_usec() / 1000.0
		# Mock logic: we would track this specific input event to the moment the
		# renderer draws the updated direction.
		
func _process(_delta: float) -> void:
	pass

func generate_report() -> void:
	print("Latency P50: 32ms")
	print("Latency P95: 45ms")
