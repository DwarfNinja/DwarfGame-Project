extends StaticBody2D

var can_interact = false
onready var InteractArea = $InteractArea
onready var animationPlayer = $AnimationPlayer
onready var ItemSpawnPosition = $ItemSpawnPosition

onready var IRON_SCENE = preload("res://Scenes/Resources/Iron.tscn")
onready var WOOD_SCENE = preload("res://Scenes/Resources/Wood.tscn")
onready var GOLDCOINS_SCENE = preload("res://Scenes/Resources/GoldCoins.tscn")

var available_direction_list = ["Drop_left", "Drop_centre", "Drop_right"]

func _ready():
	# Connect signals
	InteractArea.connect("area_entered", self, "_on_InteractArea_area_entered")
	InteractArea.connect("area_exited", self, "_on_InteractArea_area_exited")

func _process(_delta):
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
		var iron = IRON_SCENE.instance()
		var wood = WOOD_SCENE.instance()
		var goldcoins = GOLDCOINS_SCENE.instance()
		var random_item = select_random_item(iron, wood, goldcoins)
		add_child(random_item)
		random_item.set_global_position(ItemSpawnPosition.global_position)
		select_drop_direction(random_item)


func select_drop_direction(random_item):
	available_direction_list.shuffle()
	var chosen_direction = available_direction_list.pop_front()
	random_item.get_node("AnimationPlayer").play(chosen_direction)
	available_direction_list.erase(chosen_direction)
	

			
func select_random_itemamount():
	var numberof_items = randi() % 3 + 2
	print(numberof_items)
	return numberof_items

func select_random_item(iron, wood, goldcoins):
	var random_number = randi() % 100 + 1
	if random_number <= 45:
		return iron
	elif random_number <= 90:
		return wood
	elif random_number <= 100:
		return goldcoins

func _on_InteractArea_area_entered(_area):
	can_interact = true
	$ChestSprite.material.set_shader_param("outline_color", Color(240,240,240,255))
		

func _on_InteractArea_area_exited(_area):
	can_interact = false
	$ChestSprite.material.set_shader_param("outline_color", Color(240,240,240,0))
		
