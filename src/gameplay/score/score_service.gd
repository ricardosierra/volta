class_name ScoreService
extends Node

var runner_scores: Dictionary = {}
var config: Resource

func _init(cfg: Resource) -> void:
	config = cfg

func ensure_runner(id: int) -> void:
	if not runner_scores.has(id):
		runner_scores[id] = ScoreState.new()

func handle_seal(runner_id: int, cells: PackedInt32Array, stolen: Dictionary, surge_mult: float = 1.0, push_mult: float = 1.0) -> void:
	ensure_runner(runner_id)
	var state: ScoreState = runner_scores[runner_id]
	
	var base_mult = config.get_meta("base_seal_mult", 10)
	var steal_mult = config.get_meta("steal_mult", 15)
	
	var pts = 0
	var stolen_count = 0
	for count in stolen.values():
		stolen_count += count
		
	var pure_new = cells.size() - stolen_count
	pts += pure_new * base_mult
	pts += stolen_count * steal_mult
	
	pts = int(pts * surge_mult * push_mult)
	
	state.territory_points += pts
	if cells.size() > state.largest_seal:
		state.largest_seal = cells.size()
		
	_recalc(runner_id)

func handle_break(killer: int) -> void:
	ensure_runner(killer)
	var state: ScoreState = runner_scores[killer]
	state.break_points += config.get_meta("break_base", 500)
	_recalc(killer)

func handle_survival_tick(runners: Array) -> void:
	var tick_pts = config.get_meta("survival_tick", 1)
	for r in runners:
		if r.state.fsm_state != RunnerState.State.ELIMINATED:
			ensure_runner(r.state.id)
			var state: ScoreState = runner_scores[r.state.id]
			state.survival_points += tick_pts
			_recalc(r.state.id)

func _recalc(id: int) -> void:
	var state = runner_scores[id]
	state.total_score = state.territory_points + state.break_points + state.survival_points
