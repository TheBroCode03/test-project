extends Resource
class_name InventoryData

@export var size: int = 20
var slots: Array[SlotData] = []

func _init():
	slots.resize(size)
	for i in range(size):
		slots[i] = SlotData.new()

func add_item(item: ItemData, amount: int) -> bool:
	# try stacking first
	for slot in slots:
		if slot.item == item and slot.quantity < item.max_stack:
			slot.quantity += amount
			return true
	
	# then find empty slot
	for slot in slots:
		if slot.is_empty():
			slot.set_item(item, amount)
			return true
	
	return false
