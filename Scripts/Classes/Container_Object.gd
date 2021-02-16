extends Interactable_Object

export (Resource) var drop_table_def

onready var animationPlayer = $AnimationPlayer
onready var ItemSpawnPosition = $ItemSpawnPosition

var available_direction_list = ["Drop_left", "Drop_centre", "Drop_right"]

func _ready():
	pass

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

func drop_items():
	available_direction_list = ["Drop_left", "Drop_centre", "Drop_right"]
	for item in range(1, select_random_itemamount()):
		var RANDOM_ITEM = select_item_from_drop_table()
		var random_item = load(RANDOM_ITEM.item_scenepath).instance()
		add_child(random_item, true)
		random_item.set_global_position(ItemSpawnPosition.global_position)
		play_drop_animation(random_item)
#TODO: add legible_unique_name to all add_child() calls

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


func play_drop_animation(random_item):
	available_direction_list.shuffle()
	var chosen_direction = available_direction_list.pop_front()
	random_item.get_node("AnimationPlayer").play(chosen_direction)
	available_direction_list.erase(chosen_direction)
	

func select_random_itemamount():
	var numberof_items = randi() % 3 + 2
	return numberof_items

