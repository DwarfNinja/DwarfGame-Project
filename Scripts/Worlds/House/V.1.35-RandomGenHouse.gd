extends Node2D


onready var CROSS = get_node("HouseRooms/Cross")

onready var NE_RIGHTANGLE = get_node("HouseRooms/RightAngle/N-E_RightAngle")
onready var SE_RIGHTANGLE = get_node("HouseRooms/RightAngle/S-E_RightAngle")
onready var NW_RIGHTANGLE = get_node("HouseRooms/RightAngle/N-W_RightAngle")
onready var SW_RIGHTANGLE = get_node("HouseRooms/RightAngle/S-W_RightAngle")

onready var SQUARESPACE_SW_E = get_node("HouseRooms/SquareSpace_SW-E")
onready var ZIG_NW_S = get_node("HouseRooms/Zig_NW-S")

onready var SQUARE_4x5 = get_node("HouseShapes/Square_4x2")
onready var SE_5x2 = get_node("HouseShapes/SE_3x2")
onready var Hor_4x1 = get_node("HouseShapes/Hor_4x1")

onready var IRON_SCENE = preload("res://Scenes/Resources/Iron.tscn")
onready var WOOD_SCENE = preload("res://Scenes/Resources/Wood.tscn")
onready var GOLDCOINS_SCENE = preload("res://Scenes/Resources/GoldCoins.tscn")

onready var CHEST = preload("res://Scenes/Interactables/Chest.tscn")

onready var VILLAGER_SCENE = preload("res://Scenes/KinematicBodies/Villager.tscn")

onready var DOOR_SCENE = preload("res://Scenes/Objects/Door.tscn")
onready var PLAYER_SCENE = preload("res://Scenes/KinematicBodies/Player.tscn")

var rooms = 0
var max_rooms = 3

var shapes = 0
var max_shapes

var max_items
var max_enemies

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
	
	if max_rooms == 2:
		max_shapes = 4
		max_items = 3
		max_enemies = 1
	if max_rooms == 3:
		max_shapes = 6
		max_items = 4
		max_enemies = 1
		
	check_randomroom_viability()


func _process(_delta):
	if Input.is_action_just_pressed("key_r"):
		get_tree().reload_current_scene()
		print("___________________________________")
	if Input.is_action_just_pressed("ui_accept"):
		check_extent_of_shape()
	if Input.is_action_just_pressed("key_f"):
		fill_outer_walls()
#	var mouse_pos = get_global_mouse_position()
#	var cell = $Nav2D/Walls.world_to_map(mouse_pos)
#	print(cell)
		
func set_random_room(random_room, random_room_location, _last_room_location):
	var random_room_walls = random_room.get_node("Walls")
	var random_room_floor = random_room.get_node("Floor")
	var random_room_area = random_room.get_node("Area")
	var random_room_indexes = random_room.get_node("Indexes")
	print("ROOM = ", random_room.get_name())
	print("ROOM CALC = ", last_room_location, " + ", random_room_location, "=", last_room_location + random_room_location)
	for cell in random_room_walls.get_used_cells():
		$Nav2D/Walls.set_cell(cell.x + (random_room_location.x + last_room_location.x), 
		cell.y + (random_room_location.y + last_room_location.y), random_room_walls.get_cellv(cell), 
		false, false, false, random_room_walls.get_cell_autotile_coord(cell.x, cell.y))
	
	for cell in random_room_floor.get_used_cells():
		$Nav2D/Floor.set_cell(cell.x + (random_room_location.x + last_room_location.x), 
		cell.y + (random_room_location.y + last_room_location.y), random_room_floor.get_cellv(cell), 
		false, false, false, random_room_floor.get_cell_autotile_coord(cell.x, cell.y))
	
	for cell in random_room_area.get_used_cells(): 
		$Nav2D/Area.set_cell(cell.x + (random_room_location.x + last_room_location.x), 
		cell.y + (random_room_location.y + last_room_location.y), random_room_area.get_cellv(cell), 
		false, false, false, random_room_area.get_cell_autotile_coord(cell.x, cell.y))
	
	for cell in random_room_indexes.get_used_cells():
		$Nav2D/Indexes.set_cell(cell.x + (random_room_location.x + last_room_location.x), 
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
	
	for cell in $Nav2D/Area.get_used_cells():
		var shape_origin = $Nav2D/Area.get_cell(cell.x, cell.y)
		var shape_origin_left = $Nav2D/Area.get_cell(cell.x - 1, cell.y)
		var shape_width_extent = $Nav2D/Area.get_cell(cell.x + (random_shape_width), cell.y)
		var shape_height_extent = $Nav2D/Area.get_cell(cell.x, cell.y + (random_shape_height -1))
		var shape_rect_se_corner = $Nav2D/Area.get_cell(cell.x + (random_shape_height -1), cell.y + (random_shape_height -1))
		
		var walls_origin = $Nav2D/Walls.get_cell(cell.x, cell.y)
		var walls_origin_left = $Nav2D/Walls.get_cell(cell.x - 1, cell.y)
		var walls_width_extent = $Nav2D/Walls.get_cell(cell.x + (random_shape_width), cell.y)
		var walls_height_extent = $Nav2D/Walls.get_cell(cell.x, cell.y + (random_shape_height -1))
		var walls_rect_se_corner = $Nav2D/Walls.get_cell(cell.x + (random_shape_height -1), cell.y + (random_shape_height -1))
		# Checks certain cells in $Nav2D/Area and $Nav2D/Walls if it is able the place the shape
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
		place_player_spawn()
		place_enemies()
		place_items()
		Events.emit_signal("randomgenhouse_loaded")
		
		
func set_shape(random_shape, selected_shape_location):
	# Sets the shape in $Nav2D/Walls
	for cell in random_shape.get_used_cells():
		$Nav2D/Walls.set_cell(selected_shape_location.x + cell.x, selected_shape_location.y + cell.y, random_shape.get_cellv(cell), 
		false, false, false, random_shape.get_cell_autotile_coord(cell.x, cell.y))
	shapes += 1
	
	
func finalize_random_gen():
	fill_outer_walls()
	clear_used_cells()
	clear_index_tile_conflict()
	update_allcell_bitmasks()
	
	
func fill_outer_walls():
	var perimiter_cells = []
	for _cycles in range(0,2):
		for cell in $Nav2D/Floor.get_used_cells():
			if $Nav2D/Floor.get_cell(cell.x - 1, cell.y) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x - 1 * index, cell.y))
					
			if $Nav2D/Floor.get_cell(cell.x + 1, cell.y) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x + 1 * index, cell.y))
					
			if $Nav2D/Floor.get_cell(cell.x, cell.y - 1) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x, cell.y - 1 * index))
					
			if $Nav2D/Floor.get_cell(cell.x, cell.y + 1) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x, cell.y + 1 * index))
					
		
		for cell in perimiter_cells:
			$Nav2D/Walls.set_cell(cell.x, cell.y, 0, 
			false, false, false, $Nav2D/Walls.get_cell_autotile_coord(cell.x, cell.y))
			$Nav2D/Floor.set_cell(cell.x, cell.y, 9, 
			false, false, false, $Nav2D/Walls.get_cell_autotile_coord(cell.x, cell.y))
	
	
func clear_used_cells():
	for cell in $Nav2D/Walls.get_used_cells():
		if $Nav2D/Walls.get_cellv(cell) == 16 or $Nav2D/Walls.get_cellv(cell) == 3:
			# Clear cells in Area used in $Nav2D/Walls
			$Nav2D/Area.set_cell(cell.x, cell.y, -1)
			# Clear cells in Indexes used in $Nav2D/Walls
			$Nav2D/Indexes.set_cell(cell.x, cell.y, -1)
	
	
func clear_index_tile_conflict():
	for cell in $Nav2D/Indexes.get_used_cells():
		if $Nav2D/Area.get_cellv(cell) == -1:
			# If index tile is not equal to a player spawn tile
			if $Nav2D/Indexes.get_cellv(cell) != 14:
				$Nav2D/Indexes.set_cell(cell.x, cell.y, -1)
	
func update_allcell_bitmasks():
	for cell in $Nav2D/Walls.get_used_cells():
		$Nav2D/Walls.update_bitmask_area(cell)
	
	
func get_tiles_in_rectangle(node_pos, rect_width, rect_height):
	# Rect sides must be of uneven numbers
	var rect_tiles = []
	var top_left = node_pos - (Vector2(floor(rect_width / 2), floor(rect_height / 2)))
	var bottom_right = node_pos + (Vector2(floor(rect_width / 2), floor(rect_height / 2))) 
	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			rect_tiles.append(Vector2(x, y)) # or get_cell(x, y) or however you want it represented
#	print("RECT_TILES = ", rect_tiles)
	return rect_tiles
	
# Look at code, can be imporved line 262-265
func place_items():
	var item_tile_array = $Nav2D/Indexes.get_used_cells_by_id(13)
	var random_item_positions = select_random_item_positions(item_tile_array)
	for i in range(0, random_item_positions.size()):
		var iron = IRON_SCENE.instance()
		var wood = WOOD_SCENE.instance()
		var goldcoins = GOLDCOINS_SCENE.instance()
		var chest = CHEST.instance()
		var random_item = select_random_lootable(chest)
		var tilepos = $Nav2D/Walls.map_to_world(random_item_positions[i])
		random_item.set_position(tilepos + Vector2(8,8))
		$Nav2D/Walls.add_child(random_item)
		$Nav2D/Indexes.set_cellv(random_item_positions[i], -1)
		$Nav2D/Area.set_cellv(random_item_positions[i], -1)
	
	
func place_enemies():
	var enemy_tile_array = $Nav2D/Indexes.get_used_cells_by_id(12)
	var random_enemy_positions = select_random_enemy_positions(enemy_tile_array)
	print("random_enemy_positions = ", random_enemy_positions)
	for i in range(0, random_enemy_positions.size()):
		var villager = VILLAGER_SCENE.instance()
		var random_enemy = select_random_enemy(villager)
		var tilepos = $Nav2D/Walls.map_to_world(random_enemy_positions[i])
		random_enemy.set_position(tilepos + Vector2(7.99, 8.01)) #Bug in Nav2D where it rounds up ints?
		$Nav2D/Walls.add_child(random_enemy)
		$Nav2D/Indexes.set_cellv(random_enemy_positions[i], -1)
		
		
func place_player_spawn():
	var spawn_tile_array = $Nav2D/Indexes.get_used_cells_by_id(14)
	var random_spawn_position = select_random_spawn_position(spawn_tile_array)
	var player = PLAYER_SCENE.instance()
	var tilepos = $Nav2D/Walls.map_to_world(random_spawn_position)
	place_door(random_spawn_position, tilepos)
	$Nav2D/Walls.add_child(player)
	player.set_position(tilepos + Vector2(16,-8))
	$Nav2D/Walls/Player/AnimationTree.set("parameters/Idle/blend_position", Vector2(0,-0.1))
	for i in range(0, spawn_tile_array.size()):
		$Nav2D/Indexes.set_cell(spawn_tile_array[i].x, spawn_tile_array[i].y, -1)
		
func place_door(random_spawn_position, tilepos):
	var door = DOOR_SCENE.instance()
	$Nav2D/Walls.set_cell(random_spawn_position.x, random_spawn_position.y, -1)
	$Nav2D/Walls.set_cell(random_spawn_position.x + 1 , random_spawn_position.y, -1)
	$Nav2D/Walls.add_child(door)
	door.set_position(tilepos)
	var spawn_zone_width = 15
	var spawn_zone_height = 8
	# Door position offset to compensate so the zone isn't in the wall
	var spawn_zone = get_tiles_in_rectangle(
		$Nav2D/Walls.world_to_map(door.position) - 
		Vector2(0,ceil(spawn_zone_height/2) + 1), spawn_zone_width, spawn_zone_height)
	
	for cell in spawn_zone:
		if $Nav2D/Indexes.get_cellv(cell) != -1:
			$Nav2D/Indexes.set_cell(cell.x, cell.y, -1)
		

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
	var room_list = [CROSS, NE_RIGHTANGLE, SE_RIGHTANGLE, NW_RIGHTANGLE,
	 SW_RIGHTANGLE, SQUARESPACE_SW_E, ZIG_NW_S]
	room_list.shuffle()
	return room_list.pop_front()
	
func select_randomroom_direction(possible_new_room_locations):
	possible_new_room_locations.shuffle()
	return possible_new_room_locations.pop_front()
	
func select_random_shape():
	var shape_list = [SQUARE_4x5, SE_5x2, Hor_4x1]
	shape_list.shuffle()
	return shape_list.pop_front()
	
func select_random_shape_location(possible_shape_locations):
	possible_shape_locations.shuffle()
	return possible_shape_locations.pop_front()
	
	
func select_random_item_positions(item_tile_array):
	var random_item_positions = []
	if item_tile_array.size() < max_items:
		max_items = item_tile_array.size()
	for _items in range(0, max_items):
		item_tile_array.shuffle()
		if item_tile_array[0] != null:
			random_item_positions.append(item_tile_array.pop_front())
	return random_item_positions
	
func select_random_lootable(chest):
	var random_number = randi() % 100 + 1
	if random_number <= 40:
		return chest
	elif random_number <= 80:
		return chest
	elif random_number <= 100:
		return chest
	
	
func select_random_enemy_positions(enemy_tile_array):
	var random_enemy_positions = []
	if enemy_tile_array.size() < max_enemies:
		max_enemies = enemy_tile_array.size()
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
		
