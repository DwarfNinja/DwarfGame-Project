extends Node2D


onready var CROSS = get_node("HouseRooms/Cross")

onready var N_E_RIGHTANGLE = get_node("HouseRooms/RightAngle/N-E_RightAngle")
onready var S_E_RIGHTANGLE = get_node("HouseRooms/RightAngle/S-E_RightAngle")
onready var N_W_RIGHTANGLE = get_node("HouseRooms/RightAngle/N-W_RightAngle")
onready var S_W_RIGHTANGLE = get_node("HouseRooms/RightAngle/S-W_RightAngle")

onready var SQUARESPACE_SW_E = get_node("HouseRooms/SquareSpace_SW-E")
onready var ZIG_NW_S = get_node("HouseRooms/Zig_NW-S")

onready var SQUARE_4x5 = get_node("HouseShapes/Square_4x5")

onready var IRON_SCENE = preload("res://Scenes/Resources/Iron.tscn")
onready var WOOD_SCENE = preload("res://Scenes/Resources/WoodenLogs.tscn")
onready var GOLDCOINS_SCENE = preload("res://Scenes/Resources/GoldCoins.tscn")

onready var VILLAGER_SCENE = preload("res://Scenes/KinematicBodies/Villager.tscn")

onready var DOOR_SCENE = preload("res://Scenes/Door.tscn")
onready var PLAYER_SCENE = preload("res://Scenes/KinematicBodies/Player.tscn")

var rooms = 0
var max_rooms = 3

var shapes = 0
var max_shapes = 5

var max_items = 4
var max_enemies = 3

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
	if Input.is_action_just_pressed("ui_accept"):
		check_extent_of_shape()
	if Input.is_action_just_pressed("key_f"):
		fill_outer_walls()
		
		
func set_random_room(random_room, random_room_location, _last_room_location):
	var random_room_walls = random_room.get_node("Walls")
	var random_room_floor = random_room.get_node("Floor")
	var random_room_area = random_room.get_node("Area")
	var random_room_indexes = random_room.get_node("Indexes")
	print("ROOM = ", random_room.get_name())
	print("ROOM CALC = ", last_room_location, " + ", random_room_location, "=", last_room_location + random_room_location)
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
	
	for cell in random_room_indexes.get_used_cells():
		$Indexes.set_cell(cell.x + (random_room_location.x + last_room_location.x), 
		cell.y + (random_room_location.y + last_room_location.y), random_room_indexes.get_cellv(cell), 
		false, false, false, random_room_indexes.get_cell_autotile_coord(cell.x, cell.y))
	
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
			if (last_room_location + converted_randomroom_position) in current_occupied_room_locations:
				get_tree().reload_current_scene()
#				check_randomroom_viability()
#				return
					
			set_random_room(new_room, converted_randomroom_position, last_room_location)
			print("OCCUPIED ROOMS = ", current_occupied_room_locations)
			last_room = new_room.duplicate()
			last_room_location = converted_randomroom_position + last_room_location
			current_occupied_room_locations.append(last_room_location)
#			print("selected_randomroom_direction is:  ", selected_randomroom_direction)
#			last_room.openings[last_room.mapping[selected_randomroom_direction]] = false
#			print("last_room.openings is:  ", last_room.openings)
		
	else:
		# Place first room on (0,0)
		last_room_location = room_pos_start
		set_random_room(new_room, room_pos_start, last_room_location)
		last_room = new_room.duplicate()
		current_occupied_room_locations.append(last_room_location)
	
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
		var shape_origin_left = $Area.get_cell(cell.x - 1, cell.y)
		var shape_width_extent = $Area.get_cell(cell.x + (random_shape_width -1), cell.y)
		var shape_height_extent = $Area.get_cell(cell.x, cell.y + (random_shape_height -1))
		var shape_rect_se_corner = $Area.get_cell(cell.x + (random_shape_height -1), cell.y + (random_shape_height -1))
		
		var walls_origin = $Walls.get_cell(cell.x, cell.y)
		var walls_origin_left = $Walls.get_cell(cell.x - 1, cell.y)
		var walls_width_extent = $Walls.get_cell(cell.x + (random_shape_width -1), cell.y)
		var walls_height_extent = $Walls.get_cell(cell.x, cell.y + (random_shape_height -1))
		var walls_rect_se_corner = $Walls.get_cell(cell.x + (random_shape_height -1), cell.y + (random_shape_height -1))
		# Checks certain cells in $Area and $Walls if it is able the place the shape
		if shape_origin == 11 and shape_width_extent == 11 and shape_height_extent == 11 and shape_rect_se_corner == 11 and shape_origin_left == 11:
			if walls_origin == -1 and walls_width_extent == -1 and walls_height_extent == -1 and walls_rect_se_corner == -1 and walls_origin_left == -1:
				possible_shape_locations.append(cell)
	
	# Selects a random shape location if there is at least 1 viable location
	if possible_shape_locations != []:
		var selected_shape_location = select_random_shape_location(possible_shape_locations)
		set_shape(random_shape, selected_shape_location)
			
	if shapes < max_shapes:
		check_extent_of_shape()
	else:
		finalize_random_gen()
		clear_index_tile_conflict()
		place_items()
		place_enemies()
		place_player_spawn()
		
		
func set_shape(random_shape, selected_shape_location):
	# Sets the shape in $Walls
	for cell in random_shape.get_used_cells():
		$Walls.set_cell(selected_shape_location.x + cell.x, selected_shape_location.y + cell.y, random_shape.get_cellv(cell), 
		false, false, false, random_shape.get_cell_autotile_coord(cell.x, cell.y))
	shapes += 1


func fill_outer_walls():
	var perimiter_cells = []
	for _cycles in range(0,2):
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
	
	
func clear_used_area():
	for cell in $Walls.get_used_cells():
		if $Walls.get_cellv(cell) == 16:
			$Area.set_cell(cell.x, cell.y, -1, 
			false, false, false)
	
	
func clear_index_tile_conflict():
	for cell in $Indexes.get_used_cells():
		if $Area.get_cellv(cell) == -1:
			if $Indexes.get_cellv(cell) != 14:
				$Indexes.set_cell(cell.x, cell.y, -1)
			
			
func place_items():
	var item_tile_array = $Indexes.get_used_cells_by_id(13)
			
	for i in range(0, select_random_item_positions(item_tile_array).size()):
		var iron = IRON_SCENE.instance()
		var wood = WOOD_SCENE.instance()
		var goldcoins = GOLDCOINS_SCENE.instance()
		var random_item = select_random_item(iron, wood, goldcoins)
		var tilepos = $Walls.map_to_world(item_tile_array[i])
		random_item.set_position(tilepos + Vector2(8,8))
		$Indexes.set_cell(item_tile_array[i].x, item_tile_array[i].y, -1)
		$Walls.add_child(random_item)
	
	
func place_enemies():
	var enemy_tile_array = $Indexes.get_used_cells_by_id(12)
	
	for i in range(0, select_random_enemy_positions(enemy_tile_array).size()):
		var villager = VILLAGER_SCENE.instance()
		var random_enemy = select_random_enemy(villager)
		var tilepos = $Walls.map_to_world(enemy_tile_array[i])
		random_enemy.set_position(tilepos + Vector2(8,8))
		$Indexes.set_cell(enemy_tile_array[i].x, enemy_tile_array[i].y, -1)
		$Walls.add_child(random_enemy)
		
		
func place_player_spawn():
	var spawn_tile_array = $Indexes.get_used_cells_by_id(14)
	print("SPAWN TILE ARRAY = ",spawn_tile_array)
	var random_spawn_position = select_random_spawn_position(spawn_tile_array)
	var door = DOOR_SCENE.instance()
	var player = PLAYER_SCENE.instance()
	var tilepos = $Walls.map_to_world(random_spawn_position)
	$Walls.set_cell(random_spawn_position.x, random_spawn_position.y, -1)
	$Walls.set_cell(random_spawn_position.x + 1 , random_spawn_position.y, -1)
	door.set_position(tilepos)
	$Walls.add_child(door)
	player.set_position(tilepos + Vector2(16,-8))
	$Walls.add_child(player)
	$Walls/Player/AnimationTree.set("parameters/Idle/blend_position", Vector2(0,-0.1))
	for i in range(0, spawn_tile_array.size()):
		$Indexes.set_cell(spawn_tile_array[i].x, spawn_tile_array[i].y, -1)
		
		
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
	var room_list = [CROSS, N_E_RIGHTANGLE, S_E_RIGHTANGLE, N_W_RIGHTANGLE,
	 S_W_RIGHTANGLE, SQUARESPACE_SW_E, ZIG_NW_S]
	room_list.shuffle()
	return room_list.pop_front()
	
func select_randomroom_direction(possible_new_room_locations):
	possible_new_room_locations.shuffle()
	return possible_new_room_locations.pop_front()
	
	
func select_random_shape():
	var shape_list = [SQUARE_4x5]
	shape_list.shuffle()
	return shape_list.pop_front()
	
func select_random_shape_location(possible_shape_locations):
	possible_shape_locations.shuffle()
	return possible_shape_locations.pop_front()
	
	
func select_random_item_positions(item_tile_array):
	var random_item_positions = []
	for _items in range(0, max_items):
		item_tile_array.shuffle()
		random_item_positions.append(item_tile_array.pop_front())
	return random_item_positions
	
func select_random_item(iron, wood, goldcoins):
	var random_number = randi() % 100 + 1
	if random_number <= 40:
		return iron
	elif random_number <= 80:
		return wood
	elif random_number <= 100:
		return goldcoins


func select_random_enemy_positions(enemy_tile_array):
	var random_enemy_positions = []
	for _enemy in range(0, max_enemies):
		enemy_tile_array.shuffle()
		random_enemy_positions.append(enemy_tile_array.pop_front())
	return random_enemy_positions
	
func select_random_enemy(villager):
	var random_number = randi() % 100 + 1
	if random_number <= 100:
		return villager
		
func select_random_spawn_position(spawn_tile_array):
	var player_spawn
	var possible_player_spawns = []
	for tile in spawn_tile_array:
		if player_spawn == null:
			player_spawn = tile
		if tile.y > player_spawn.y:
			player_spawn = tile
	for tile in spawn_tile_array:
		if tile.y == player_spawn.y:
			possible_player_spawns.append(tile)
	possible_player_spawns.append(player_spawn)
	
	for spawn in possible_player_spawns:
		possible_player_spawns.shuffle()
	return possible_player_spawns.pop_front()
		
		
