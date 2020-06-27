extends Node2D

onready var CROSS_SHAPE = get_node("HouseShapes/Cross/Walls")
#var L_DOWN_SHAPE = load("res://Scenes/House/HouseShapes/L-Down/Walls.tscn")
onready var L_DOWN_SHAPE = get_node("HouseShapes/L_Down/Walls")
onready var L_UP_SHAPE = get_node("HouseShapes/L_Up/Walls")
onready var R_DOWN_SHAPE = get_node("HouseShapes/R_Down/Walls")
onready var R_UP_SHAPE = get_node("HouseShapes/R_Up/Walls")

var rooms = 0
var max_rooms = 4
var rooms_generated = false

var pos_for_room_0 = Vector2(0,0)
var pos_for_room_1 = Vector2(22, 0)
var pos_for_room_2 = Vector2(0, 22)
var pos_for_room_3 = Vector2(22, 22)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
func _process(_delta):
	if rooms < max_rooms:
		var random_shape = choose_random_shape([CROSS_SHAPE, L_DOWN_SHAPE, L_UP_SHAPE, R_DOWN_SHAPE, R_UP_SHAPE])
		var room_data = random_shape.get_parent().get_room_data()
		var last_room_data = room_data[0]
		var new_room_data = room_data[1]
		for i in new_room_data:
			if i in last_room_data:
				set_random_room(random_shape)
			else:
				random_shape = choose_random_shape([CROSS_SHAPE, L_DOWN_SHAPE, L_UP_SHAPE, R_DOWN_SHAPE, R_UP_SHAPE])
		
		set_random_room(random_shape)
		rooms += 1
	if rooms == max_rooms and rooms_generated == false:
		update_allcell_bitmasks()
		
		
func set_random_room(random_shape):
	for cell in random_shape.get_used_cells():
#		$Walls.set_cellv(cell, random_shape.get_cellv(cell))
		$Walls.set_cell(cell.x + get("pos_for_room_" + str(rooms)).x, cell.y + get("pos_for_room_" + str(rooms)).y, random_shape.get_cellv(cell), 
		false, false, false, random_shape.get_cell_autotile_coord(cell.x, cell.y))
#		$Walls.update_bitmask_area(cell)

func update_allcell_bitmasks():
	for cell in $Walls.get_used_cells():
		$Walls.update_bitmask_area(cell)
	rooms_generated = true

func choose_random_shape(house_shape_list):
	house_shape_list.shuffle()
	return house_shape_list.pop_front()
	
