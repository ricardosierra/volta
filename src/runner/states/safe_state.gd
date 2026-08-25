class_name SafeState
extends State

var runner: Runner

func _init(r: Runner):
	runner = r

func update(_delta: float) -> void:
	# If runner moves outside its claim, transition to DrawingTrail
	if runner:
		# Need grid reference, passed normally via match director or FSM context
		pass
