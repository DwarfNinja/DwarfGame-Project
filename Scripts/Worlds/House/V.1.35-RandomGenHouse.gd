extends Node2D

onready var HouseTileset = preload("res://HouseTileset.tres")
onready var HouseRooms = get_node("HouseRooms")
onready var HouseShapes = get_node("HouseShapes")
onready var TopConnectionEnd = get_node("ConnectionEnds/TopConnectionEnd")
onready var L_SideConnectionEnd = get_node("ConnectionEnds/L_ConnectionEnd")
onready var R_SideConnectionEnd = get_node("ConnectionEnds/R_SideConnectionEnd")

onready var Chest = preload("res://Scenes/Interactables/Chest.tscn")

onready var Villager_Scene = preload("res://Scenes/KinematicBodies/Villager.tscn")

onready var Door_Scene = preload("res://Scenes/Objects/Door.tscn")
onready var Player_Scene = preload("res://Scenes/KinematicBodies/Player.tscn")

onready var floor_tile_id = HouseTileset.find_tile_by_name("Floor")
onready var walls_tile_id = HouseTileset.find_tile_by_name("Walls")
onready var front_walls_tile_id = HouseTileset.find_tile_by_name("Walls_Wall")
onready var wall_shadow_tile_id = HouseTileset.find_tile_by_name("WallShadow")

onready var area_tile_id = HouseTileset.find_tile_by_name("Area")

onready var loot_index_tile_id = HouseTileset.find_tile_by_name("ContainerIndex")
onready var enemy_index_tile_id = HouseTileset.find_tile_by_name("EnemyIndex")
onready var spawn_index_tile_id = HouseTileset.find_tile_by_name("SpawnIndex")

var current_occupied_room_locations = []
var rooms = 0
var max_rooms = 2

var last_room
var last_room_location

var shapes = 0
var max_shapes = 0

var max_items
var max_enemies

var room_pos_start = Vector2(0,0)
var room_pos_north = Vector2(0, -23)
var room_pos_east = Vector2(23, 0)
var room_pos_south = Vector2(0, 23)
var room_pos_west = Vector2(-23, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	if max_rooms == 2:
		max_shapes = 3
		max_items = 3
		max_enemies = 3
	if max_rooms == 3:
		max_shapes = 5
		max_items = 4
		max_enemies = 4
		
	random_generation()


func _process(_delta):
	if Input.is_action_just_pressed("key_r"):
		get_tree().reload_current_scene()
		print("___________________________________")
	if Input.is_action_just_pressed("ui_accept"):
		pass

	var mouse_pos = get_global_mouse_position()
	var cell = $Nav2D/Walls.world_to_map(mouse_pos)
	
	if Input.is_action_just_pressed("key_f"):
#		var rect = get_tiles_in_rectangle(cell, 3, 3)
#		for _cell in rect:
#			if $Nav2D/Area.get_cellv(_cell) != -1:
#				if $Nav2D/Walls.get_cellv(_cell) == -1:
#					$Nav2D/Walls.set_cell(_cell.x, _cell.y, 6)
		print(cell)


func random_generation():
	check_randomroom_viability()
#	check_extent_of_shape()
	cleanup_random_gen()
	place_player_spawn()
	place_enemies()
	place_loot()
	Events.emit_signal("randomgenhouse_loaded")
	
func cleanup_random_gen():
	fill_outer_walls()
	check_unused_openings(current_occupied_room_locations)
	clear_used_cells()
	clear_index_tile_conflict()
	update_allcell_bitmasks()


func check_randomroom_viability():
	var selected_randomroom_direction
	
	while rooms < max_rooms:
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
					check_randomroom_viability()
						
				set_random_room(new_room, converted_randomroom_position, last_room_location)
				print("OCCUPIED ROOMS = ", current_occupied_room_locations)
				last_room = new_room.duplicate()
				last_room_location = converted_randomroom_position + last_room_location
				current_occupied_room_locations.append(last_room_location)
			
		else:
			# Place first room on (0,0)
			last_room_location = room_pos_start
			set_random_room(new_room, room_pos_start, last_room_location)
			last_room = new_room.duplicate()
			current_occupied_room_locations.append(last_room_location)

func set_random_room(random_room, random_room_location, _last_room_location):
	var random_room_template = select_randomroom_template(random_room)
	var random_room_floor = random_room.get_node("Floor")
	var random_room_walls = random_room_template.get_node("Walls")
	var random_room_area = random_room_template.get_node("Area")
	var random_room_indexes = random_room_template.get_node("Indexes")
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

func select_randomroom_template(random_room):
	var room_templates = random_room.get_node("Templates").get_children()
	room_templates.shuffle()
	return room_templates.pop_front()


func check_extent_of_shape():
	while shapes < max_shapes:
		var random_shape = select_random_shape()
		var random_shape_width = random_shape.shape_width
		var random_shape_height = random_shape.shape_height
		var possible_shape_locations = []
		
		for cell in $Nav2D/Area.get_used_cells():
			var shape_footprint = get_tiles_in_rectangle(cell, random_shape_width, random_shape_height)
			if shape_footprint_is_empty(shape_footprint):
				possible_shape_locations.append(cell)
	
		# Selects a random shape location if there is at least 1 viable location
		if possible_shape_locations != []:
			var selected_shape_location = select_random_shape_location(possible_shape_locations)
			set_shape(random_shape, selected_shape_location)

func shape_footprint_is_empty(shape_footprint):
	for cell in shape_footprint:
		if $Nav2D/Area.get_cellv(cell) == -1 or $Nav2D/Walls.get_cellv(cell) != -1:
			return false
	return true

func set_shape(random_shape, selected_shape_location):
	# Sets the shape in $Nav2D/Walls
	for cell in random_shape.get_used_cells():
		$Nav2D/Walls.set_cell(selected_shape_location.x + cell.x, selected_shape_location.y + cell.y, random_shape.get_cellv(cell), 
		false, false, false, random_shape.get_cell_autotile_coord(cell.x, cell.y))
	shapes += 1


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
			$Nav2D/Floor.set_cell(cell.x, cell.y, floor_tile_id, 
			false, false, false, $Nav2D/Walls.get_cell_autotile_coord(cell.x, cell.y))
			$Nav2D/Walls.set_cell(cell.x, cell.y, walls_tile_id, 
			false, false, false, $Nav2D/Walls.get_cell_autotile_coord(cell.x, cell.y))


func clear_used_cells():
	for cell in $Nav2D/Walls.get_used_cells():
		if $Nav2D/Walls.get_cellv(cell) == front_walls_tile_id:
			# Clear cells in Area used in $Nav2D/Walls
			$Nav2D/Area.set_cell(cell.x, cell.y, -1)
			# Clear cells in Indexes used in $Nav2D/Walls
			$Nav2D/Indexes.set_cell(cell.x, cell.y, -1)

#Clears Index tiles that are not in Area, ie stuck in Walls
func clear_index_tile_conflict():
	for cell in $Nav2D/Indexes.get_used_cells():
		if $Nav2D/Area.get_cellv(cell) == -1:
			# If index tile is not equal to a player spawn tile
			if $Nav2D/Indexes.get_cellv(cell) != spawn_index_tile_id:
				$Nav2D/Indexes.set_cell(cell.x, cell.y, -1)

func update_allcell_bitmasks():
	for cell in $Nav2D/Walls.get_used_cells():
		$Nav2D/Walls.update_bitmask_area(cell)


func get_tiles_in_rec_centre(node_pos, rect_width, rect_height):
	# Rect sides must be of uneven numbers
	var rect_tiles = []
	var top_left = node_pos - (Vector2(floor(rect_width / 2), floor(rect_height / 2)))
	var bottom_right = node_pos + (Vector2(floor(rect_width / 2), floor(rect_height / 2))) 
	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			rect_tiles.append(Vector2(x, y))
	return rect_tiles

func get_tiles_in_rectangle(top_left, rect_width, rect_height):
	var rect_tiles = []
	var bottom_right = top_left + Vector2(rect_width, rect_height)
	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			rect_tiles.append( Vector2(x, y) )
	return rect_tiles

#TODO: Look at code, can be improved line 262-265
func place_loot():
	var loot_tile_array = $Nav2D/Indexes.get_used_cells_by_id(loot_index_tile_id)
	var random_loot_positions = select_random_item_positions(loot_tile_array)
	for i in range(0, random_loot_positions.size()):
		var chest = Chest.instance()
		var random_loot = select_random_lootable(chest)
		var tilepos = $Nav2D/Walls.map_to_world(random_loot_positions[i])
		random_loot.set_position(tilepos + Vector2(8,8))
		$Nav2D/Walls.add_child(random_loot)
		$Nav2D/Indexes.set_cellv(random_loot_positions[i], -1)
		$Nav2D/Area.set_cellv(random_loot_positions[i], -1)


func place_enemies():
	var enemy_tile_array = $Nav2D/Indexes.get_used_cells_by_id(enemy_index_tile_id)
	var random_enemy_positions = select_random_enemy_positions(enemy_tile_array)
	print("random_enemy_positions = ", random_enemy_positions)
	for i in range(0, random_enemy_positions.size()):
		var villager = Villager_Scene.instance()
		var random_enemy = select_random_enemy(villager)
		var tilepos = $Nav2D/Walls.map_to_world(random_enemy_positions[i])
		random_enemy.set_position(tilepos + Vector2(7.99, 8.01)) #Somehow fixed a bug in Nav2D where it rounds up ints?
		$Nav2D/Walls.add_child(random_enemy)
		$Nav2D/Indexes.set_cellv(random_enemy_positions[i], -1)


func place_player_spawn():
	var spawn_tile_array = $Nav2D/Indexes.get_used_cells_by_id(spawn_index_tile_id)
	var random_spawn_position = select_random_spawn_position(spawn_tile_array)
	var player = Player_Scene.instance()
	var tilepos = $Nav2D/Walls.map_to_world(random_spawn_position)
	place_door(random_spawn_position, tilepos)
	$Nav2D/Walls.add_child(player)
	player.set_position(tilepos + Vector2(23,-8))
	player.get_node("AnimationTree").set("parameters/Idle/blend_position", Vector2(0,-0.1))
	for i in range(0, spawn_tile_array.size()):
		$Nav2D/Indexes.set_cell(spawn_tile_array[i].x, spawn_tile_array[i].y, -1)


func place_door(random_spawn_position, tilepos):
	var door = Door_Scene.instance()
	$Nav2D/Walls.set_cell(random_spawn_position.x, random_spawn_position.y, -1)
	$Nav2D/Walls.set_cell(random_spawn_position.x + 1 , random_spawn_position.y, -1)
	$Nav2D/Walls.set_cell(random_spawn_position.x + 2 , random_spawn_position.y, -1)
	$Nav2D/Walls.add_child(door)
	door.set_position(tilepos)
	place_spawn_zone(door)


func place_spawn_zone(door):
	# Position offset to compensate so the zone isn't in the wall
	var spawn_zone_width = 15
	var spawn_zone_height = 8
	var spawn_zone = get_tiles_in_rec_centre(
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
	var room_list = HouseRooms.get_children()
	room_list.shuffle()
	return room_list.pop_front()

func select_randomroom_direction(possible_new_room_locations):
	possible_new_room_locations.shuffle()
	return possible_new_room_locations.pop_front()


func select_random_shape():
	var shape_list = HouseShapes.get_children()
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
		if player_spawn.y - tile.y <= 4:
			possible_player_spawns.append(tile)
	possible_player_spawns.append(player_spawn)
	
	for spawn in possible_player_spawns:
		possible_player_spawns.shuffle()
	return possible_player_spawns.pop_front()


func check_unused_openings(room_positions):
	var top_connections = [Vector2(2,0), Vector2(11,0), Vector2(20,0)]
	var side_connections =[Vector2(0,11), Vector2(22,11)]
	
	for cell in room_positions:
		for _cell in top_connections:
			if $Nav2D/Walls.get_cellv(cell + _cell + Vector2(0,-1)) != -1 and $Nav2D/Walls.get_cellv(cell + _cell) == -1:
				set_connection_end((cell + _cell) + Vector2(-1,0), TopConnectionEnd)
				
				if $Nav2D/Walls.get_cellv(cell + _cell + Vector2(-2,3)) == wall_shadow_tile_id:
					$Nav2D/Walls.set_cell((cell.x + _cell.x + -2), (cell.y + _cell.y + 3), wall_shadow_tile_id, false, false, false, Vector2(2,0))
					
				if $Nav2D/Walls.get_cellv(cell + _cell + Vector2(2,3)) == wall_shadow_tile_id:
					$Nav2D/Walls.set_cell((cell.x + _cell.x + 2), (cell.y + _cell.y + 3), wall_shadow_tile_id, false, false, false, Vector2(2,0))

	for cell in room_positions:
		for _cell in side_connections:
			if $Nav2D/Walls.get_cellv(cell + _cell + Vector2(-1,0)) != -1 and $Nav2D/Walls.get_cellv(cell + _cell) == -1:
				set_connection_end((cell + _cell) + Vector2(0,-4), L_SideConnectionEnd)
				
			if $Nav2D/Walls.get_cellv(cell + _cell + Vector2(1,0)) != -1 and $Nav2D/Walls.get_cellv(cell + _cell) == -1:
				set_connection_end((cell + _cell) + Vector2(0,-4), R_SideConnectionEnd)

func set_connection_end(unused_opening_location, ConnectionEnd):
	for cell in ConnectionEnd.get_used_cells():
		$Nav2D/Walls.set_cell(unused_opening_location.x + cell.x, unused_opening_location.y + cell.y, ConnectionEnd.get_cellv(cell), 
		false, false, false, ConnectionEnd.get_cell_autotile_coord(cell.x, cell.y))

