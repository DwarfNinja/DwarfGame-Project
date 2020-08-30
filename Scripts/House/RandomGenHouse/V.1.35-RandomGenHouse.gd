extends Node2D


onready var CROSS = get_node("HouseRooms/Cross")

onready var N_E_RIGHTANGLE = get_node("HouseRooms/RightAngle/N-E_RightAngle")
onready var S_E_RIGHTANGLE = get_node("HouseRooms/RightAngle/S-E_RightAngle")
onready var N_W_RIGHTANGLE = get_node("HouseRooms/RightAngle/N-W_RightAngle")
onready var S_W_RIGHTANGLE = get_node("HouseRooms/RightAngle/S-W_RightAngle")


onready var SQUARESPACE_SW_E = get_node("HouseRooms/SquareSpace_SW-E")
onready var ZIG_NW_S = get_node("HouseRooms/Zig_NW-S")

onready var SQUARE_4x5 = get_node("HouseShapes/Square_4x5")


var rooms = 0
var max_rooms = 3
var shapes = 0
var max_shapes = 4

var last_room
var last_room_location
var selected_randomroom_direction
var current_occupied_room_locations = []
	
var room_pos_start = Vector2(0,0)
var room_pos_north = Vector2(0, -20)
var room_pos_east = Vector2(20, 0)
var room_pos_south = Vector2(0, 20)
var room_pos_west = Vector2(-20, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	check_randomroom_viability()
	
func _process(_delta):
	if Input.is_action_just_pressed("key_r"):
		get_tree().reload_current_scene()
		print("___________________________________")
	if Input.is_action_just_pressed("key_e"):
		check_randomroom_viability()
	if Input.is_action_just_pressed("ui_accept"):
		check_extent_of_shape()
	if Input.is_action_just_pressed("key_f"):
		fill_outer_walls()
		
func set_random_room(random_room, random_room_location, _last_room_location):
	var random_room_walls = random_room.get_node("Walls")
	var random_room_floor = random_room.get_node("Floor")
	var random_room_area = random_room.get_node("Area")
	print(random_room.get_name())
	print(last_room_location, " + ", random_room_location, "=", last_room_location + random_room_location)
	for cell in random_room_walls.get_used_cells():
		$Walls.set_cell(cell.x + (random_room_location.x + last_room_location.x), 
		cell.y + (random_room_location.y + last_room_location.y), random_room_walls.get_cellv(cell), 
		false, false, false, random_room_walls.get_cell_autotile_coord(cell.x, cell.y))
	
	for cell in random_room_floor.get_used_cells():
		$Floor.set_cell(cell.x + (random_room_location.x + last_room_location.x), 
		cell.y + (random_room_location.y + last_room_location.y), random_room_floor.get_cellv(cell), 
		false, false, false, random_room_floor.get_cell_autotile_coord(cell.x, cell.y))
	
	for cell in random_room_area.get_used_cells():
		$Area.set_cell(cell.x + (random_room_location.x + last_room_location.x), 
		cell.y + (random_room_location.y + last_room_location.y), random_room_area.get_cellv(cell), 
		false, false, false, random_room_area.get_cell_autotile_coord(cell.x, cell.y))
	rooms += 1
	
	
func check_randomroom_viability():
	var new_room = select_random_room()
	var possible_new_room_directions = []
	
	if last_room:
		for direction in last_room.openings.keys():
			if last_room.openings[direction] == true and new_room.get_connection(direction):
				possible_new_room_directions.append(direction)
		if selected_randomroom_direction:
			possible_new_room_directions.erase(last_room.mapping[selected_randomroom_direction])
				
		if possible_new_room_directions != []:
			selected_randomroom_direction = select_randomroom_direction(possible_new_room_directions)
			var converted_randomroom_position = location_of_value(selected_randomroom_direction)
			if last_room_location:
				if (last_room_location + converted_randomroom_position) in current_occupied_room_locations:
					check_randomroom_viability()
			clear_needed_chunk(new_room, converted_randomroom_position, last_room_location)
			set_random_room(new_room, converted_randomroom_position, last_room_location)
			last_room = new_room
			last_room_location = converted_randomroom_position + last_room_location
			current_occupied_room_locations.append(last_room_location)
#			print("selected_randomroom_direction is:  ", selected_randomroom_direction)
#			last_room.openings[last_room.mapping[selected_randomroom_direction]] = false
#			print("last_room.openings is:  ", last_room.openings)
			
	else:
		# Place first room on (0,0)
		last_room_location = room_pos_start
		set_random_room(new_room, room_pos_start, last_room_location)
		last_room = new_room
		
	if rooms < max_rooms:
		check_randomroom_viability()
	else:
		check_extent_of_shape()
		
		
func check_extent_of_shape():
	var random_shape = select_random_shape()
	var random_shape_width = random_shape.shape_width
	var random_shape_height = random_shape.shape_height
	var possible_shape_locations = []

	for cell in $Area.get_used_cells():
		var shape_origin = $Area.get_cell(cell.x, cell.y)
		var shape_width_extent = $Area.get_cell(cell.x + (random_shape_width -1), cell.y)
		var shape_height_extent = $Area.get_cell(cell.x, cell.y + (random_shape_height -1))
		var shape_rect_sw_corner = $Area.get_cell(cell.x + (random_shape_height -1), cell.y + (random_shape_height -1))
		
		var walls_origin = $Walls.get_cell(cell.x, cell.y)
		var walls_width_extent = $Walls.get_cell(cell.x + (random_shape_width -1), cell.y)
		var walls_height_extent = $Walls.get_cell(cell.x, cell.y + (random_shape_height -1))
		var walls_rect_sw_corner = $Walls.get_cell(cell.x + (random_shape_height -1), cell.y + (random_shape_height -1))
		# Checks certain cells in $Area and $Walls if it is able the place the shape
		if shape_origin == 11 and shape_width_extent == 11 and  shape_height_extent == 11 and shape_rect_sw_corner == 11:
			if walls_origin == -1 and walls_width_extent == -1 and walls_height_extent == -1 and walls_rect_sw_corner == -1:
				possible_shape_locations.append(cell)

	# Selects a random shape location if there is at least 1 viable location
	if possible_shape_locations != []:
		var selected_shape_location = select_random_shape_location(possible_shape_locations)
		set_shape(random_shape, selected_shape_location)
		
		
	if shapes < max_shapes:
		check_extent_of_shape()
	else:
		finalize_random_gen()
		
		
func set_shape(random_shape, selected_shape_location):
	# Sets the shape in $Walls
	for cell in random_shape.get_used_cells():
		$Walls.set_cell(selected_shape_location.x + cell.x, selected_shape_location.y + cell.y, random_shape.get_cellv(cell), 
		false, false, false, random_shape.get_cell_autotile_coord(cell.x, cell.y))
	shapes += 1


func fill_outer_walls():
	var perimiter_cells = []
	for cycles in range(0,2):
		for cell in $Floor.get_used_cells():
			if $Floor.get_cell(cell.x - 1, cell.y) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x - 1 * index, cell.y))
					
			if $Floor.get_cell(cell.x + 1, cell.y) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x + 1 * index, cell.y))
					
			if $Floor.get_cell(cell.x, cell.y - 1) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x, cell.y - 1 * index))
					
			if $Floor.get_cell(cell.x, cell.y + 1) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x, cell.y + 1 * index))
					
		
		for cell in perimiter_cells:
			$Walls.set_cell(cell.x, cell.y, 0, 
			false, false, false, $Walls.get_cell_autotile_coord(cell.x, cell.y))
			$Floor.set_cell(cell.x, cell.y, 9, 
			false, false, false, $Walls.get_cell_autotile_coord(cell.x, cell.y))
		
	
	
func finalize_random_gen():
	clear_used_area()
	fill_outer_walls()
	update_allcell_bitmasks()
	Events.emit_signal("randomgenhouse_loaded")
	
	
func update_allcell_bitmasks():
	for cell in $Walls.get_used_cells():
		$Walls.update_bitmask_area(cell)
	
	
func clear_needed_chunk(random_room, random_room_location, _last_room_location):
	var random_room_floor = random_room.get_node("Floor")
	
	for cell in random_room_floor.get_used_cells():
		$Walls.set_cell(cell.x + (random_room_location.x + last_room_location.x), 
		cell.y + (random_room_location.y + last_room_location.y), -1, 
		false, false, false)
	
	
func clear_used_area():
	for cell in $Walls.get_used_cells():
		if $Walls.get_cellv(cell) == 16:
			$Area.set_cell(cell.x, cell.y, -1, 
			false, false, false)
	
	
func location_of_value(converted_randomroom_location):
	var locations = {
	"northwest_north": room_pos_north,
	"north": room_pos_north,
	"northeast_north": room_pos_north,
	
	"northeast_east": room_pos_east,
	"east": room_pos_east,
	"southeast_east": room_pos_east,
	
	"southeast_south": room_pos_south,
	"south": room_pos_south,
	"southwest_south": room_pos_south,
	
	"southwest_west": room_pos_west,
	"west": room_pos_west,
	"northwest_west": room_pos_west
	}
	return locations[converted_randomroom_location] 
	
	
func select_random_room():
	var room_list = [CROSS, N_E_RIGHTANGLE, S_E_RIGHTANGLE, N_W_RIGHTANGLE, S_W_RIGHTANGLE, SQUARESPACE_SW_E, ZIG_NW_S]
	room_list.shuffle()
	return room_list.pop_front()
	
	
func select_random_shape():
	var shape_list = [SQUARE_4x5]
	shape_list.shuffle()
	return shape_list.pop_front()
	
	
func select_randomroom_direction(possible_new_room_locations):
	possible_new_room_locations.shuffle()
	return possible_new_room_locations.pop_front()
	
	
func select_random_shape_location(possible_shape_locations):
	possible_shape_locations.shuffle()
	return possible_shape_locations.pop_front()
