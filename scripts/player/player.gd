extends CharacterBody3D

@export var speed := 6.0
@export var mouse_sensitivity := 0.002
@export var inventory: InventoryData

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var raycast = $RayCast3D

var selected_slot := 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var ui_open = false
const ItemScene = preload("res://scenes/items/item_pickup.tscn")


func _ready():
	if !is_multiplayer_authority():
		camera.current = false
		set_process_input(false)
	if is_multiplayer_authority():
		var ui = get_tree().get_root().get_node("Main/UI/InventoryUI")
		ui.set_player(self)
# =====================
# LOOK
# =====================
func _input(event):
	if !is_multiplayer_authority():
		return
	
	if event.is_action_pressed("drop_item"):
		drop_selected()
		
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	if event.is_action_pressed("interact"):
		try_interact()
# =====================
# MOVE
# =====================
func _physics_process(delta):
	if !is_multiplayer_authority() or ui_open:
		return
	
	if raycast.is_colliding():
		var target = raycast.get_collider()
		
		if target.has_method("get_item_data"):
			target.modulate = Color(1.3, 1.3, 1.3)
	else:
		# reset ALL items (simple version)
		for item in get_tree().get_nodes_in_group("items"):
			item.modulate = Color(1,1,1)
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()

func try_interact():
	if !raycast.is_colliding():
		return
	
	var target = raycast.get_collider()
	
	if target.has_method("get_item_data"):
		request_pickup.rpc_id(1, target.get_path())

@rpc("any_peer")
func request_pickup(item_path: NodePath):
	if !multiplayer.is_server():
		return
	
	var item = get_node_or_null(item_path)
	if item == null:
		return
	sync_inventory.rpc_id(multiplayer.get_remote_sender_id(), serialize_inventory())
	var success = inventory.add_item(item.item_data, 1)
	
	if success:
		item.queue_free()
		sync_inventory.rpc_id(multiplayer.get_remote_sender_id(), inventory.slots)

func drop_selected():
	request_drop.rpc_id(1, selected_slot)

@rpc("any_peer")
func request_drop(slot_index: int):
	if !multiplayer.is_server():
		return
	
	var slot = inventory.slots[slot_index]
	
	if slot.item == null:
		return
	sync_inventory.rpc(serialize_inventory())
	# remove 1 item
	slot.quantity -= 1
	
	var item_data = slot.item
	
	if slot.quantity <= 0:
		slot.item = null
	
	# spawn world item
	spawn_dropped_item(item_data)
	
	var sender_id = multiplayer.get_remote_sender_id()
	sync_inventory.rpc_id(sender_id, serialize_inventory())

func spawn_dropped_item(item_data: ItemData):
	var item = ItemScene.instantiate()
	item.item_data = item_data
	
	# spawn slightly in front of player
	var forward = -transform.basis.z
	item.global_position = global_position + forward * 2
	
	get_tree().get_root().get_node("Main/World").add_child(item)
	

@rpc("authority")
func sync_inventory(data):
	for i in range(data.size()):
		if data[i] == null:
			inventory.slots[i].clear()
		else:
			var item = load(data[i]["item"])
			inventory.slots[i].set_item(item, data[i]["quantity"])
	
	update_ui()
	
func update_ui():
	var ui = get_tree().get_root().get_node("Main/UI/InventoryUI")
	if ui:
		ui.update_inventory(inventory)
	
	var hotbar = get_tree().get_root().get_node("Main/UI/HotbarUI")
	if hotbar:
		hotbar.update_from_inventory(inventory)
		
func serialize_inventory():
	var data = []
	for slot in inventory.slots:
		if slot.item:
			data.append({
				"item": slot.item.resource_path,
				"quantity": slot.quantity
			})
		else:
			data.append(null)
	return data
