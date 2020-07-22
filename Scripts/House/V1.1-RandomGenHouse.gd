extends Node2D

onready var CROSS_SHAPE = get_node("HouseShapes/Cross")
onready var L_DOWN_SHAPE = get_node("HouseShapes/L_Down")
onready var L_UP_SHAPE = get_node("HouseShapes/L_Up")
onready var R_DOWN_SHAPE = get_node("HouseShapes/R_Down")
onready var R_UP_SHAPE = get_node("HouseShapes/R_Up")
onready var SQUARESPACE_SW_E = get_node("HouseShapes/SquareSpace_SW-E")
onready var ZIG_NW_S = get_node("HouseShapes/Zig_NW-S")

var rooms = 0
var max_rooms = 2
var rooms_generated = false
var first_room_placed = false
var first_room_data
var possible_new_room_locations = []
var checking_room = false

var first_room_pos = Vector2(0,0)
var room_pos_0 = Vector2(0, -20)
var room_pos_1 = Vector2(20, 0)
var room_pos_2 = Vector2(0, 20)
var room_pos_3 = Vector2(-20, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
func _process(_delta):
	if Input.is_action_just_pressed("key_r"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("key_e"):
		fill_with_walls()
	if first_room_placed == false:
		set_first_room()
		
	if first_room_placed == true and rooms < max_rooms and checking_room == false:
		check_randomroom_viability()
		
	if rooms == max_rooms and rooms_generated == false:
		update_allcell_bitmasks()
		
func set_first_room():
	var first_shape = choose_random_shape()
	var first_shape_walls = first_shape.get_node("Walls")
	first_room_data = first_shape.get_room_data()[0]
	
	for cell in first_shape_walls.get_used_cells():
		$Walls.set_cell(cell.x + first_room_pos.x, cell.y + first_room_pos.y, first_shape_walls.get_cellv(cell), 
		false, false, false, first_shape_walls.get_cell_autotile_coord(cell.x, cell.y))
		
	rooms += 1
	first_room_placed = true
		
		
func set_random_room(random_shape_walls, random_shape_floor, new_random_room_location):
	for cell in random_shape_walls.get_used_cells():
		$Walls.set_cell(cell.x + get("room_pos_" + str(new_random_room_location)).x, 
		cell.y + get("room_pos_" + str(new_random_room_location)).y, random_shape_walls.get_cellv(cell), 
		false, false, false, random_shape_walls.get_cell_autotile_coord(cell.x, cell.y))
	for cell in random_shape_floor.get_used_cells():
		$Floor.set_cell(cell.x + get("room_pos_" + str(new_random_room_location)).x/2, 
		cell.y + get("room_pos_" + str(new_random_room_location)).y/2, random_shape_floor.get_cellv(cell), 
		false, false, false, random_shape_floor.get_cell_autotile_coord(cell.x, cell.y))
	rooms += 1
	
	
func check_randomroom_viability():
	var random_shape = choose_random_shape()
	var random_shape_walls = random_shape.get_node("Walls")
	var random_shape_floor = random_shape.get_node("Floor")
	var new_room_data = random_shape.get_room_data()[1]
	
	var count = 0
	checking_room = true
	for i in range(0, first_room_data.size()):
		count += 1
		var value1 = first_room_data[i]
		var value2 = new_room_data[i]
		if value1 == value2:
			if value1 == true and value2 == true:
				possible_new_room_locations.append(location_of_value(i))
	
	if count == 12 and possible_new_room_locations != []:
		
		var new_random_room_location = choose_random_location(possible_new_room_locations)
		set_random_room(random_shape_walls, random_shape_floor, new_random_room_location)
	else:
		checking_room = false
		

func update_allcell_bitmasks():
	for cell in $Walls.get_used_cells():
		$Walls.update_bitmask_area(cell)
	rooms_generated = true

func fill_with_walls(rect = Rect2(-40, -40, 80, 80)):
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if $Floor.get_cell(x,y) == -1:
				$Walls.set_cell(x, y, 0)

func location_of_value(value):
	if value in range(0,3):
		value = 0
	elif value in range(3,6):
		value = 1
	elif value in range(6,9):
		value = 2
	elif value in range(9,12):
		value = 3
	return value

func choose_random_shape():
	var house_shape_list = [CROSS_SHAPE, L_DOWN_SHAPE, L_UP_SHAPE, R_DOWN_SHAPE, R_UP_SHAPE, SQUARESPACE_SW_E, ZIG_NW_S]
	house_shape_list.shuffle()
	return house_shape_list.pop_front()
	
func choose_random_location(possible_new_room_locations):
	possible_new_room_locations.shuffle()
	return possible_new_room_locations.pop_front()
