class_name BotIntentOverlay
extends Control

var scheduler: AIScheduler
var font: Font

func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	set_process(true)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not scheduler: return
	
	for b in scheduler.bots:
		var r: Runner = b.runner
		var brain: BotBrain = b.brain
		
		if r.state.fsm_state == RunnerState.State.ELIMINATED:
			continue
			
		var pos := r.state.position
		var text := "ID: %d" % r.state.id
		if brain.current_action:
			text += "\n%s" % brain.current_action.action_name
			
		draw_string(ThemeDB.fallback_font, pos + Vector2(-30, -30), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)
