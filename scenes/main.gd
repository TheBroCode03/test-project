extends Node3D

@onready var menu = $UI/MainMenu
@onready var multiplayer_manager = $MultiplayerManager
@onready var host_lobby_menu: Control = $UI/HostLobbyMenu

var current_lobby = {
	"name": "",
	"password": "",
	"is_private": false
}

func _ready():
	menu.host_pressed.connect(_on_host)
	menu.join_pressed.connect(_on_join)
	host_lobby_menu.create_lobby.connect(_on_create_lobby)

func _on_host():
	menu.hide()
	host_lobby_menu.visible = true

func _on_join(ip):
	multiplayer_manager.join(ip)
	menu.hide()
	
func _on_create_lobby(name, password, is_private):
	current_lobby.name = name
	current_lobby.password = password
	current_lobby.is_private = is_private
	menu.visible = false
	start_host()

func start_host():
	print("START HOST CALLED")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer
	host_lobby_menu.visible = false
	load_game_scene.rpc()
	# 👇 ADD THIS
	LobbyRegistry.lobbies.append({
		"name": current_lobby.name,
		"ip": get_local_ip(),
		"has_password": current_lobby.is_private,
		"password": current_lobby.password
	})

func get_local_ip() -> String:
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172."):
			return ip
	return "127.0.0.1"

@rpc("authority", "call_local")
func load_game_scene():
	print("GAME SCENE LOADED")
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	menu.visible = false
	
