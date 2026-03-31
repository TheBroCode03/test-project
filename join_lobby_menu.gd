extends Control
@onready var main_menu: Control = $"../MainMenu"
@onready var join_lobby_menu: Control = $"."


func refresh_lobbies():
	var list = $LobbyList
	list.clear()
	
	for lobby in LobbyRegistry.lobbies:
		var text = lobby.name
		if lobby.has_password:
			text += " 🔒"
		
		list.add_item(text)

func _on_join_pressed():
	var list = $VBoxContainer/LobbyList
	
	if list.get_selected_items().is_empty():
		print("No lobby selected")
		return
	
	var index = list.get_selected_items()[0]
	var lobby = LobbyRegistry.lobbies[index]
	
	# password check
	if lobby.has_password:
		if $VBoxContainer/PasswordInput.text != lobby.password:
			print("Wrong password")
			return
	
	# 👇 Call main to join
	get_tree().get_root().get_node("Main").join_game(lobby.ip)

func _on_back_pressed() -> void:
	main_menu.visible = true
	join_lobby_menu.visible = false
