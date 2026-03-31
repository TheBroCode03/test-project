extends Control

@onready var ip_input = $"Panel/VBoxContainer/IP Input"
@onready var host_lobby_menu = $"../HostLobbyMenu"
@onready var main_menu: Control = $"."
@onready var join_menu: Control = $"../JoinLobbyMenu"

signal host_pressed
signal join_pressed(ip)


func _on_host_pressed() -> void:
	main_menu.visible = false
	host_lobby_menu.visible = true
	

func _on_join_pressed() -> void:
	main_menu.visible = false
	join_menu.visible = true
