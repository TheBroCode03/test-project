extends Control

@onready var name_input = $PanelContainer/CenterContainer/VBoxContainer/LobbyNameInput
@onready var password_input = $PanelContainer/CenterContainer/VBoxContainer/PasswordInput
@onready var status: CheckBox = $PanelContainer/CenterContainer/VBoxContainer/Status



@onready var main_menu: Control = $"../MainMenu"
@onready var host_lobby_menu: Control = $"."


signal create_lobby(name, password, is_private)

func _on_create_pressed():
	print("CREATE LOBBY TRIGGERED")
	var lobby_name = name_input.text.strip_edges()
	var password = password_input.text
	
	if lobby_name == "":
		print("Lobby needs a name")
		return
	
	create_lobby.emit(lobby_name, password, status)
	main_menu.visible = false
	print("Lobby: " + lobby_name)
	print("Lobby: " + password)



func _on_back_pressed() -> void:
	main_menu.visible = true
	host_lobby_menu.visible = false


func _on_status_toggled(toggled_on: bool) -> void:
	var toggle_state: int
	toggle_state = toggle_state + 1
	
