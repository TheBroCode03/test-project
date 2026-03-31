extends Node3D
@onready var hotbar_ui: Control = $UI/HotbarUI

func _ready():
	if multiplayer.is_server():
		spawn_player(multiplayer.get_unique_id())
		
const PlayerScene = preload("res://scenes/player.tscn")

func spawn_player(peer_id):
	var player = PlayerScene.instantiate()
	player.name = str(peer_id)
	add_child(player)
	
	player.set_multiplayer_authority(peer_id)
	hotbar_ui.visible = true
