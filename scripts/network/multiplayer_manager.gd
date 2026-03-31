extends Node
class_name MultiManager

const PORT = 9999
const PlayerScene = preload("res://scenes/player.tscn")
var current_lobby = {
	"name": "",
	"password": "",
	"is_private": false
}

@onready var players_node = get_node("/root/Main/Players")

func get_local_ip() -> String:
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172."):
			return ip
	return "127.0.0.1"
	
func host():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	spawn_player(1)
	show_host_ip()

func show_host_ip():
	var label = get_tree().get_root().get_node("Main/UI/HostIPLabel")
	label.text = "Your IP: " + get_local_ip() + " PORT: 9999"
	label.visible = true

func join(ip):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(_on_connected)
	var label = get_tree().get_root().get_node("Main/UI/HostIPLabel")
	label.visible = false

func _on_connected():
	spawn_player(multiplayer.get_unique_id())

func spawn_player(id):
	var player = PlayerScene.instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	
	players_node.add_child(player)
	host()
