extends PanelContainer

var slot_index: int
var inventory_ui

@onready var icon = $TextureRect
@onready var label = $Label

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited():
	modulate = Color(1, 1, 1)

# =====================
# DRAG START
# =====================
func _get_drag_data(_pos):
	if icon.texture == null:
		return null
	
	var preview = TextureRect.new()
	preview.texture = icon.texture
	preview.custom_minimum_size = Vector2(48, 48)
	set_drag_preview(preview)
	
	return slot_index

# =====================
# CAN DROP
# =====================
func _can_drop_data(_pos, data):
	return typeof(data) == TYPE_INT

# =====================
# DROP
# =====================
func _drop_data(_pos, data):
	inventory_ui.request_swap(slot_index, data)

func set_selected(value: bool):
	if value:
		add_theme_color_override("border_color", Color(0.4, 0.7, 1))
	else:
		add_theme_color_override("border_color", Color(0.2, 0.2, 0.25))
