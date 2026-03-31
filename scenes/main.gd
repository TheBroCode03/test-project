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
	$UI/JoinLobbyMenu.join_requested.connect(_on_join_connected)

func _on_host():
	menu.hide()
	host_lobby_menu.visible = true

func _on_join_connected(ip):
	print("Client connected, loading game")
	load_game_scene.rpc_id(1)

func _on_join(ip):
	print("Joining IP:", ip)

	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, 9999)

	if err != OK:
		push_error("Failed to connect")
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_failed)
	
func _on_connected():
	print("Connected to server!")
	load_game_scene.rpc_id(1)

func _on_failed():
	print("Connection failed")
	
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
	LobbyRegistry.register_lobby.rpc({
		"name": current_lobby.name,
		"ip": get_local_ip(),
		"has_password": current_lobby.is_private,
		"password": current_lobby.password
	})
	start_broadcast()

var broadcast_timer

func start_broadcast():
	var udp = PacketPeerUDP.new()
	udp.set_broadcast_enabled(true)
	
	broadcast_timer = Timer.new()
	broadcast_timer.wait_time = 1.0
	broadcast_timer.autostart = true
	broadcast_timer.one_shot = false
	
	add_child(broadcast_timer)
	
	broadcast_timer.timeout.connect(func():
		var data = {
			"name": current_lobby.name,
			"ip": get_local_ip(),
			"port": 9999
		}
		
		var msg = JSON.stringify(data)
		udp.set_dest_address("255.255.255.255", 9998)
		udp.put_packet(msg.to_utf8_buffer())
	)

func get_local_ip() -> String:
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172."):
			print(ip)
			return ip
	return "127.0.0.1"

@rpc("authority", "call_local")
func load_game_scene():
	print("GAME SCENE LOADED")
	get_tree().change_scene_to_file("res://scripts/network/game_scene.tscn")
	menu.visible = false
	
	
