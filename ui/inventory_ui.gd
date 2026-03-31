extends Control

@onready var grid = $Panel/MarginContainer/GridContainer
const SlotScene = preload("res://scenes/slot_ui.tscn")

var player
var slots_ui = []

func _ready():
	setup_slots(24)

func open():
	visible = true
	player.ui_open = true
	
	update_inventory(player.inventory) # 👈 ADD THIS
	
	scale = Vector2(0.8, 0.8)
	modulate.a = 0
	
	var t = create_tween()
	t.tween_property(self, "scale", Vector2.ONE, 0.15)
	t.tween_property(self, "modulate:a", 1.0, 0.15)

func close():
	visible = false
	
func _input(event):
	if event.is_action_pressed("ui_inventory"):
		$"/root/Main/UI/InventoryUI".visible = !visible
		
func setup_slots(count: int):
	for i in range(count):
		var slot = SlotScene.instantiate()
		grid.add_child(slot)
		
		slot.slot_index = i
		slot.inventory_ui = self
		
		slots_ui.append(slot)
		
func update_inventory(inv: InventoryData):
	for i in range(slots_ui.size()):
		var slot_data = inv.slots[i]
		var slot_ui = slots_ui[i]
		
		if !slot_data.is_empty():
			slot_ui.get_node("TextureRect").texture = slot_data.item.icon
			slot_ui.get_node("Label").text = str(slot_data.quantity)
		else:
			slot_ui.get_node("TextureRect").texture = null
			slot_ui.get_node("Label").text = ""
			
func request_swap(to_index, from_index):
	player.request_swap.rpc_id(1, from_index, to_index)
	
func set_player(p):
	player = p
