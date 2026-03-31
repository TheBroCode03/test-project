extends Node

var lobbies = []

@rpc("any_peer")
func register_lobby(lobby_data):
	lobbies.append(lobby_data)
	print("Lobby registered:", lobby_data)
