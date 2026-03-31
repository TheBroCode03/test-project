extends Resource
class_name SlotData

@export var item: ItemData = null
@export var quantity: int = 0

func set_item(new_item: ItemData, amount: int):
	item = new_item
	quantity = amount

func clear():
	item = null
	quantity = 0

func is_empty() -> bool:
	return item == null
