extends Node2D

export(Resource) var room_def
export(Resource) var shape_def

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
var bitmasks_updated = false
var first_room_placed = false
var all_rooms_placed = false
var checking_room = false
var random_room_hor_depth = 0
var random_room_ver_depth = 0

var room_pos_start = Vector2(0,0)
var room_pos_north = Vector2(0, -20)
var room_pos_east = Vector2(20, 0)
var room_pos_south = Vector2(0, 20)
var room_pos_west = Vector2(-20, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
#	set_first_room()
	
func _process(_delta):
	if Input.is_action_just_pressed("key_r"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("key_e"):
		check_randomroom_viability()
		
		
func set_random_room(random_room, random_room_location):
	var random_room_walls = random_room.get_node("Walls")
	var random_room_floor = random_room.get_node("Floor")
	var random_room_area = random_room.get_node("Area")
	
	for cell in random_room_walls.get_used_cells():
		$Walls.set_cell(cell.x + (random_room_location.x * random_room_hor_depth), 
		cell.y + (random_room_location.y * random_room_ver_depth), random_room_walls.get_cellv(cell), 
		false, false, false, random_room_walls.get_cell_autotile_coord(cell.x, cell.y))
	
	for cell in random_room_floor.get_used_cells():
		$Floor.set_cell(cell.x + (random_room_location.x * random_room_hor_depth), 
		cell.y + (random_room_location.y * random_room_ver_depth), random_room_floor.get_cellv(cell), 
		false, false, false, random_room_floor.get_cell_autotile_coord(cell.x, cell.y))
	
	for cell in random_room_area.get_used_cells():
		$Area.set_cell(cell.x + (random_room_location.x * random_room_hor_depth), 
		cell.y + (random_room_location.y * random_room_ver_depth), random_room_area.get_cellv(cell), 
		false, false, false, random_room_area.get_cell_autotile_coord(cell.x, cell.y))
	rooms += 1
#	print((get("room_pos_" + str(random_room_location)).x * random_room_hor_depth))
#	print((get("room_pos_" + str(random_room_location)).y * random_room_ver_depth))
	
	
func check_randomroom_viability():
	var new_room = select_random_room()
	var possible_new_room_direction = []
	
	if last_room:
		for direction in last_room.openings.keys():
			if last_room.openings[direction] == true and new_room.get_connection(direction):
				possible_new_room_direction.append(direction)

		if possible_new_room_direction != []:
			var selected_randomroom_direction = select_randomroom_direction(possible_new_room_direction)
			var converted_randomroom_location = location_of_value(selected_randomroom_direction)
			if last_room:
				last_room.openings[selected_randomroom_direction] = false
			clear_needed_chunk(new_room, converted_randomroom_location)
			set_random_room(new_room, converted_randomroom_location)
			last_room = new_room
			
	else:
		set_random_room(new_room, room_pos_start)
		last_room = new_room
		
	if rooms < max_rooms:
		check_randomroom_viability()
#	else:
#		check_extent_of_shape()
		
		
func check_extent_of_shape():
	var random_shape = select_random_shape()
	var random_shape_width = random_shape.shape_width
	var random_shape_height = random_shape.shape_height
	var possible_shape_locations = []
	
	for cell in $Area.get_used_cells():
		var shape_width_extent = $Area.get_cell(cell.x + (random_shape_width -1), cell.y)
		var shape_height_extent = $Area.get_cell(cell.x, cell.y + (random_shape_height -1))
		var shape_rect_sw_corner = $Area.get_cell(cell.x + (random_shape_height -1), cell.y + (random_shape_height -1))
		
		var walls_width_extent = $Walls.get_cell(cell.x + (random_shape_width -1), cell.y)
		var walls_height_extent = $Walls.get_cell(cell.x, cell.y + (random_shape_height -1))
		var walls_rect_sw_corner = $Walls.get_cell(cell.x + (random_shape_height -1), cell.y + (random_shape_height -1))
		
		# Checks certain cells in $Area and $Walls if it is able the place the shape
		if shape_width_extent == 11 and  shape_height_extent == 11 and shape_rect_sw_corner == 11:
			if walls_width_extent == 11 and walls_height_extent == 11 and walls_rect_sw_corner == -1:
				possible_shape_locations.append(cell)
				
	# Selects a random shape location if there is at least 1 viable location
	if possible_shape_locations != []:
		var selected_shape_location = select_random_shape_location(possible_shape_locations)
		set_shape(random_shape, selected_shape_location)
	else:
		check_extent_of_shape()
		
		
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


func finalize_random_gen():
	clear_used_area()
	update_allcell_bitmasks()
	Events.emit_signal("randomgenhouse_loaded")
	
	
func update_allcell_bitmasks():
	for cell in $Walls.get_used_cells():
		$Walls.update_bitmask_area(cell)
	bitmasks_updated = true
	
	
func clear_needed_chunk(random_room, random_room_location):
	var random_room_floor = random_room.get_node("Floor")
	
	for cell in random_room_floor.get_used_cells():
		$Walls.set_cell(cell.x + (random_room_location.x * random_room_hor_depth), 
		cell.y + (random_room_location.y * random_room_ver_depth), -1, 
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
	print("kaas")
	possible_new_room_locations.shuffle()
	print(possible_new_room_locations[0])
	return possible_new_room_locations.pop_front()
	
	
func select_random_shape_location(possible_shape_locations):
	possible_shape_locations.shuffle()
	return possible_shape_locations.pop_front()