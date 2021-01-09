extends StaticBody2D

var can_interact = false

export (Resource) var drop_table_def

onready var ContainerSprite = get_node(drop_table_def.container_name.capitalize() + "Sprite") 
onready var InteractArea = $InteractArea
onready var animationPlayer = $AnimationPlayer
onready var ItemSpawnPosition = $ItemSpawnPosition

var available_direction_list = ["Drop_left", "Drop_centre", "Drop_right"]

func _ready():
	# Connect signals
	InteractArea.connect("area_entered", self, "_on_InteractArea_area_entered")
	InteractArea.connect("area_exited", self, "_on_InteractArea_area_exited")

func _process(_delta):
	print(drop_table_def.get_name())
	if can_interact == true:
		if Input.is_action_just_pressed("key_e"):
			if animationPlayer.assigned_animation == "Close":
				place_items()
				animationPlayer.play("Open")
			elif animationPlayer.assigned_animation == "Open":
				animationPlayer.play("Close")
			else:
				place_items()
				animationPlayer.play("Open")
#			Events.emit_signal("entered_chest", self)
		if Input.is_action_just_pressed("key_esc"):
			Events.emit_signal("exited_chest", self)

func place_items():
	available_direction_list = ["Drop_left", "Drop_centre", "Drop_right"]
	for item in range(1, select_random_itemamount()):
		var RANDOM_ITEM = select_item_from_drop_table()
		var random_item = load(RANDOM_ITEM.packedscene_path).instance()
		add_child(random_item)
		random_item.set_global_position(ItemSpawnPosition.global_position)
		play_drop_animation(random_item)



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


func _on_InteractArea_area_entered(_area):
	can_interact = true
	ContainerSprite.material.set_shader_param("outline_color", Color(240,240,240,255))
		

func _on_InteractArea_area_exited(_area):
	can_interact = false
	ContainerSprite.material.set_shader_param("outline_color", Color(240,240,240,0))
		
