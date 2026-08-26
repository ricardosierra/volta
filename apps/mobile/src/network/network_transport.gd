class_name NetworkTransport
extends Node

var peer: ENetMultiplayerPeer

func start_server(port: int = 7777) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 32)
	multiplayer.multiplayer_peer = peer
	print("Server listening on port ", port)

func start_client(ip: String = "127.0.0.1", port: int = 7777) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
