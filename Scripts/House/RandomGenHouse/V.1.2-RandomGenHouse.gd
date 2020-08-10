extends Node2D

onready var CROSS_ROOM = get_node("HouseRooms/Cross")

onready var L_DOWN_ROOM = get_node("HouseRooms/RightAngle/L_Down")
onready var L_UP_ROOM = get_node("HouseRooms/RightAngle/L_Up")
onready var R_DOWN_ROOM = get_node("HouseRooms/RightAngle/R_Down")
onready var R_UP_ROOM = get_node("HouseRooms/RightAngle/R_Up")

onready var SQUARESPACE_SW_E = get_node("HouseRooms/SquareSpace_SW-E")
onready var ZIG_NW_S = get_node("HouseRooms/Zig_NW-S")

onready var SQUARE_4x5 = get_node("HouseShapes/Square_4x5")


var rooms = 0
var max_rooms = 2
var shapes = 0
var max_shapes = 4

var bitmasks_updated = false
var first_room_placed = false
var all_rooms_placed = false
var first_room_data
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
		set_shape()
	if first_room_placed == false:
		set_first_room()
		
	if first_room_placed == true and rooms < max_rooms and checking_room == false:
		check_randomroom_viability()
		
	if shapes < max_shapes:
		set_shape()
		
	if rooms == max_rooms and bitmasks_updated == false and all_rooms_placed == true and shapes == max_shapes:
		clear_used_area()
		update_allcell_bitmasks()
		Events.emit_signal("randomgenhouse_loaded")
		
func set_first_room():
	var first_room = choose_random_room()
	var first_room_walls = first_room.get_node("Walls")
	var first_room_area = first_room.get_node("Area")
	first_room_data = first_room.get_room_data()[0]
	
	for cell in first_room_walls.get_used_cells():
		$Walls.set_cell(cell.x + first_room_pos.x, cell.y + first_room_pos.y, first_room_walls.get_cellv(cell), 
		false, false, false, first_room_walls.get_cell_autotile_coord(cell.x, cell.y))
	for cell in first_room_area.get_used_cells():
		$Area.set_cell(cell.x + first_room_pos.x, cell.y + first_room_pos.y, first_room_area.get_cellv(cell), 
		false, false, false)
	rooms += 1
	first_room_placed = true
		
		
func set_random_room(random_room_walls, random_room_floor, random_room_area, new_random_room_location):
	for cell in random_room_walls.get_used_cells():
		$Walls.set_cell(cell.x + get("room_pos_" + str(new_random_room_location)).x, 
		cell.y + get("room_pos_" + str(new_random_room_location)).y, random_room_walls.get_cellv(cell), 
		false, false, false, random_room_walls.get_cell_autotile_coord(cell.x, cell.y))
	for cell in random_room_floor.get_used_cells():
		$Floor.set_cell(cell.x + get("room_pos_" + str(new_random_room_location)).x, 
		cell.y + get("room_pos_" + str(new_random_room_location)).y, random_room_floor.get_cellv(cell), 
		false, false, false, random_room_floor.get_cell_autotile_coord(cell.x, cell.y))
	for cell in random_room_area.get_used_cells():
		$Area.set_cell(cell.x + get("room_pos_" + str(new_random_room_location)).x, 
		cell.y + get("room_pos_" + str(new_random_room_location)).y, random_room_area.get_cellv(cell), 
		false, false, false, random_room_area.get_cell_autotile_coord(cell.x, cell.y))
	rooms += 1
	
	
func check_randomroom_viability():
	var random_room = choose_random_room()
	var random_room_walls = random_room.get_node("Walls")
	var random_room_floor = random_room.get_node("Floor")
	var random_room_area = random_room.get_node("Area")
	var new_room_data = random_room.get_room_data()[1]
	var possible_new_room_locations = []
	
	var count = 0
	checking_room = true
	for i in range(0, 11):
		count += 1
		var value1 = first_room_data[i]
		var value2 = new_room_data[i]
		if value1 == value2:
			if value1 == true and value2 == true:
				possible_new_room_locations.append(location_of_value(i))
	
	if count == 11 and possible_new_room_locations != []:
		var chosen_randomroom_location = choose_randomroom_location(possible_new_room_locations)
		clear_needed_chunk(random_room_floor, chosen_randomroom_location)
		set_random_room(random_room_walls, random_room_floor, random_room_area, chosen_randomroom_location)
		all_rooms_placed = true
	else:
		checking_room = false
		
		
func set_shape():
	var random_shape = choose_random_shape()
	var random_shape_width = random_shape.shape_width
	var random_shape_height = random_shape.shape_height
	var possible_shape_locations = []
	var chosen_shape_location
	
	for cell in $Area.get_used_cells():
		var shape_width_extent = $Area.get_cell(cell.x + (random_shape_width -1), cell.y)
		var shape_height_extent = $Area.get_cell(cell.x, cell.y + (random_shape_height -1))
		var shape_rect_sw_corner = $Area.get_cell(cell.x + (random_shape_height -1), cell.y + (random_shape_height -1))
		
		var walls_width_extent = $Walls.get_cell(cell.x + (random_shape_width -1), cell.y)
		var walls_height_extent = $Walls.get_cell(cell.x, cell.y + (random_shape_height -1))
		var walls_rect_sw_corner = $Walls.get_cell(cell.x + (random_shape_height -1), cell.y + (random_shape_height -1))
		# Checks certain cells in $Area and $Walls if it is able the place the shape
		if shape_width_extent == 11 and shape_height_extent == 11 and shape_rect_sw_corner == 11:
			if walls_width_extent == -1 and walls_height_extent == -1 and walls_rect_sw_corner == -1:
				possible_shape_locations.append(cell)
	# Chooses a random shape location if there is at least 1 viable location
	if possible_shape_locations != []:
		chosen_shape_location = choose_random_shape_location(possible_shape_locations)
	else:
		set_shape()
	# Sets the shape in $Walls
	for cell in random_shape.get_used_cells():
		$Walls.set_cell(chosen_shape_location.x + cell.x, chosen_shape_location.y + cell.y, random_shape.get_cellv(cell), 
		false, false, false, random_shape.get_cell_autotile_coord(cell.x, cell.y))
	shapes += 1
	

func update_allcell_bitmasks():
	for cell in $Walls.get_used_cells():
		$Walls.update_bitmask_area(cell)
	bitmasks_updated = true


func clear_needed_chunk(random_room_floor, new_random_room_location):
	for cell in random_room_floor.get_used_cells():
		$Walls.set_cell(cell.x + get("room_pos_" + str(new_random_room_location)).x, 
		cell.y + get("room_pos_" + str(new_random_room_location)).y, -1, 
		false, false, false)

func clear_used_area():
	for cell in $Walls.get_used_cells():
		if $Walls.get_cellv(cell) == 16:
			$Area.set_cell(cell.x, cell.y, -1, 
			false, false, false)


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


func choose_random_room():
	var room_list = [CROSS_ROOM, L_DOWN_ROOM, L_UP_ROOM, R_DOWN_ROOM, R_UP_ROOM, SQUARESPACE_SW_E, ZIG_NW_S]
	room_list.shuffle()
	return room_list.pop_front()
	
	
func choose_random_shape():
	var shape_list = [SQUARE_4x5]
	shape_list.shuffle()
	return shape_list.pop_front()
	
	
func choose_randomroom_location(possible_new_room_locations):
	possible_new_room_locations.shuffle()
	return possible_new_room_locations.pop_front()
	
	
func choose_random_shape_location(possible_shape_locations):
	possible_shape_locations.shuffle()
	return possible_shape_locations.pop_front()
