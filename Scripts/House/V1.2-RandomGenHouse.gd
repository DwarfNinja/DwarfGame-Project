extends Node2D

onready var CROSS_SHAPE = get_node("HouseShapes/Cross")
onready var L_DOWN_SHAPE = get_node("HouseShapes/L_Down")
onready var L_UP_SHAPE = get_node("HouseShapes/L_Up")
onready var R_DOWN_SHAPE = get_node("HouseShapes/R_Down")
onready var R_UP_SHAPE = get_node("HouseShapes/R_Up")

var rooms = 0
var max_rooms = 2
var rooms_generated = false
var first_room_placed = false
var first_room_data
var possible_new_room_locations = []
var new_random_room_location
var checking_rooms = false

var first_room_pos = Vector2(0,0)
var room_pos_0 = Vector2(0, -20)
var room_pos_1 = Vector2(20, 0)
var room_pos_2 = Vector2(0, 20)
var room_pos_3 = Vector2(-20, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
func _process(_delta):
	if first_room_placed == false:
		set_first_room()
		
	if first_room_placed == true and rooms < max_rooms and checking_rooms == false:
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
		
		
func set_random_room(random_shape_walls, random_shape_floor):
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
	checking_rooms = true
	for i in range(0, first_room_data.size()):
		count += 1
		var value1 = first_room_data[i]
		var value2 = new_room_data[i]
		if value1 == value2:
			if value1 == true and value2 == true:
				possible_new_room_locations.append(i)
	
	if count == 4 and possible_new_room_locations != []:
		new_random_room_location = choose_random_location(possible_new_room_locations)
		set_random_room(random_shape_walls, random_shape_floor)
	else:
		checking_rooms = false
		

func update_allcell_bitmasks():
	for cell in $Walls.get_used_cells():
		$Walls.update_bitmask_area(cell)
	rooms_generated = true

func choose_random_shape():
	var house_shape_list = [CROSS_SHAPE, L_DOWN_SHAPE, L_UP_SHAPE, R_DOWN_SHAPE, R_UP_SHAPE]
	house_shape_list.shuffle()
	return house_shape_list.pop_front()
	
func choose_random_location(possible_new_room_locations):
	possible_new_room_locations.shuffle()
	return possible_new_room_locations.pop_front()
