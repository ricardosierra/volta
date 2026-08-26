class_name MatchResult
extends RefCounted

var winner_id: int
var placements: Array # Array of dictionaries: {id: int, claim: float, score: int}
var match_time: float
var cause: String # "TIME", "DOMINATION", "LAST_MAN_STANDING", "ABANDON"

func _init(w_id: int, pl: Array, t: float, c: String) -> void:
	winner_id = w_id
	placements = pl
	match_time = t
	cause = c
