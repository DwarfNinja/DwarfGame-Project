extends Interactable_Entity

export (Resource) var drop_table_def

onready var ItemScene = preload("res://Scenes/Items/Item.tscn")
onready var animationPlayer = $AnimationPlayer
onready var ItemSpawnPosition = $ItemSpawnPosition

var direction_list = [
	Vector2(22,-20), Vector2(0,-20), Vector2(-22,-20),
	Vector2(22,0), Vector2(-22,0),
	Vector2(-22,20), Vector2(0,20), Vector2(22,20)
	]

func _process(_delta):
	if can_interact == true:
		if Input.is_action_just_pressed("key_e"):
			if animationPlayer.assigned_animation == "Close":
				drop_items()
				animationPlayer.play("Open")
			elif animationPlayer.assigned_animation == "Open":
				animationPlayer.play("Close")
			else:
				drop_items()
				animationPlayer.play("Open")
#			Events.emit_signal("entered_chest", self)
		if Input.is_action_just_pressed("key_esc"):
			Events.emit_signal("exited_container", self)

func set_facing_direction():
	pass

func drop_items():
	var available_direction_list = direction_list.duplicate()
	
	for _item in range(1, select_random_itemamount()):
		var random_item_resource = select_item_from_drop_table()
		var random_item = ItemScene.instance()
		random_item.itemDef = random_item_resource
		add_child(random_item, true)
		random_item.set_global_position(ItemSpawnPosition.global_position)
		var random_direction = choose_random_drop_direction(available_direction_list)
		random_item.play_chestdrop_animation(random_direction)
# TODO: add legible_unique_name to all add_child() calls

func select_item_from_drop_table():
	var drop_table = drop_table_def.drop_table
	var total_drop_chance = 0
	var cumulative_drop_chance = 0
	
	for drop_table_entry in drop_table:
		total_drop_chance += drop_table_entry.drop_rate
		
	var rng = randi() % total_drop_chance
	for drop_table_entry in drop_table:
		cumulative_drop_chance += drop_table_entry.drop_rate
	# if the RNG is <= item cumulated total_drop_chance then drop that item
		if rng <= cumulative_drop_chance:
			return drop_table_entry.item
	return null


func choose_random_drop_direction(available_direction_list):
	available_direction_list.shuffle()
	return available_direction_list.pop_front()
	
func select_random_itemamount():
	var numberof_items = randi() % 3 + 2
	return numberof_items

