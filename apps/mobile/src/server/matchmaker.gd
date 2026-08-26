class_name Matchmaker
extends Node

var queued_players: Array[int] = []
var max_players: int = 4

func add_player(peer_id: int) -> void:
	queued_players.append(peer_id)
	if queued_players.size() >= max_players:
		_start_match(queued_players.duplicate())
		queued_players.clear()

func remove_player(peer_id: int) -> void:
	queued_players.erase(peer_id)
	
func _start_match(players: Array[int]) -> void:
	# Instantiate MatchDirector and assign inputs to peer IDs
	print("Starting match with peers: ", players)
