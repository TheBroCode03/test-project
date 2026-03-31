extends Control

var selected_index = 0
var slots = []

func _ready():
	slots = $HBoxContainer.get_children()
	update_selection()

func _input(event):
	if event.is_action_pressed("hotbar_1"):
		select(0)
	if event.is_action_pressed("hotbar_2"):
		select(1)
	# etc...

func select(index):
	selected_index = index
	update_selection()

func update_selection():
	for i in range(slots.size()):
		if i == selected_index:
			slots[i].modulate = Color(1.3, 1.3, 1.3)
		else:
			slots[i].modulate = Color(1, 1, 1)
			
func update_from_inventory(inv: InventoryData):
	for i in range(slots.size()):
		var slot_data = inv.slots[i]
		
		if !slot_data.is_empty():
			slots[i].get_node("TextureRect").texture = slot_data.item.icon
		else:
			slots[i].get_node("TextureRect").texture = null
