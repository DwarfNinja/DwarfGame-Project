extends Node2D

# Tileset
onready var HouseTileset: TileSet = preload("res://TileSets/HouseTileset.tres")

# Node references
onready var HouseRooms: Node2D = get_node("HouseRooms") as Node2D
onready var HouseShapes: Node2D = get_node("HouseShapes") as Node2D
onready var TopConnectionEnd: TileMap = get_node("ConnectionEnds/TopConnectionEnd") as TileMap
onready var L_SideConnectionEnd: TileMap = get_node("ConnectionEnds/L_ConnectionEnd") as TileMap
onready var R_SideConnectionEnd: TileMap = get_node("ConnectionEnds/R_SideConnectionEnd") as TileMap

#TileMap references
onready var Walls: TileMap = get_node("Nav2D/Walls") as TileMap
onready var Floor: TileMap = get_node("Nav2D/Floor") as TileMap
onready var Areas: TileMap = get_node("Nav2D/Areas") as TileMap
onready var Indexes: TileMap = get_node("Nav2D/Indexes") as TileMap
onready var Props: TileMap = get_node("Nav2D/Props") as TileMap

# Containers
onready var Chest: PackedScene = preload("res://Scenes/Interactables/Chest.tscn")

# KinematicBodies
onready var Villager_Scene: PackedScene = preload("res://Scenes/KinematicBodies/Villager.tscn")
onready var Player: KinematicBody2D = get_node("Nav2D/Walls/Player") as KinematicBody2D

# Objects
onready var Door_Scene: PackedScene = preload("res://Scenes/Entities/Door.tscn")
onready var PlayerGhost: Node2D = get_node("Nav2D/Walls/PlayerGhost") as Node2D

# TileIDs Tiles
onready var floor_tile_id: int = HouseTileset.find_tile_by_name("Floor")
onready var walls_tile_id: int = HouseTileset.find_tile_by_name("Walls")
onready var front_walls_tile_id: int = HouseTileset.find_tile_by_name("Front_Wall")
onready var wall_shadow_tile_id: int = HouseTileset.find_tile_by_name("WallShadow")

# TileIDs Indexes
onready var area_tile_id: int = HouseTileset.find_tile_by_name("AreaIndex")
onready var loot_index_tile_id: int = HouseTileset.find_tile_by_name("ContainerIndex")
onready var enemy_index_tile_id: int = HouseTileset.find_tile_by_name("EnemyIndex")
onready var spawn_index_tile_id: int = HouseTileset.find_tile_by_name("SpawnIndex")

# DropTables
onready var Container_DropTable: Resource = preload("res://Resources/Drop_Tables/ContainerDropTable.tres") as Resource
onready var Enemies_DropTable: Resource = preload("res://Resources/Drop_Tables/EnemiesDropTable.tres") as Resource

var current_occupied_room_locations: Array = []
var rooms: int = 0
var max_rooms: int = 2

var last_room: Node2D
var last_room_location: Vector2

var shapes: int = 0
var max_shapes: int = 0

var spawn_zone: Array

var max_containers: int
var max_enemies: int

# Map offset coordinations for placement of rooms
var room_pos_start: Vector2
var room_pos_north: Vector2
var room_pos_east: Vector2
var room_pos_south: Vector2
var room_pos_west: Vector2

#var room_pos_start: Vector2 = Vector2(0,0)
#var room_pos_north: Vector2 = Vector2(0, -23)
#var room_pos_east: Vector2 = Vector2(23, 0)
#var room_pos_south: Vector2 = Vector2(0, 23)
#var room_pos_west: Vector2 = Vector2(-23, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	if max_rooms == 2:
		max_shapes = 3
		max_containers = 3
		max_enemies = 1 #3
	if max_rooms == 3:
		max_shapes = 5
		max_containers = 4
		max_enemies = 1 #4
	
	setup()
	random_generation()


func _process(_delta) -> void:
	if Input.is_action_just_pressed("key_r"):
		get_tree().reload_current_scene()
		print("___________________________________")
	if Input.is_action_just_pressed("ui_accept"):
		pass

	var mouse_pos: Vector2 = get_global_mouse_position()
	var cell: Vector2 = Walls.world_to_map(mouse_pos)
	
	if Input.is_action_just_pressed("key_f"):
#		var rect = get_tiles_in_rectangle(cell, 3, 3)
#		for _cell in rect:
#			if Areas.get_cellv(_cell) != -1:
#				if Walls.get_cellv(_cell) == -1:
#					Walls.set_cell(_cell.x, _cell.y, 6)
		print(cell)


func setup() -> void:
	var tilemap_rect = Floor.get_used_rect()
	var tilemap_rectsize_x = tilemap_rect.size.x
	var tilemap_rectsize_y = tilemap_rect.size.y
	
	room_pos_start = Vector2(0,0)
	room_pos_north = Vector2(0, -tilemap_rectsize_y)
	room_pos_east = Vector2(tilemap_rectsize_x, 0)
	room_pos_south = Vector2(0, tilemap_rectsize_y)
	room_pos_west = Vector2(-tilemap_rectsize_x, 0)

func random_generation() -> void:
	check_randomroom_viability()
	check_extent_of_shape()
	cleanup_random_gen()
	place_player_spawn()
	place_enemies()
	place_loot()
	Events.emit_signal("RandomGenHouseLoaded")
	
func cleanup_random_gen() -> void:
	fill_outer_walls()
	check_unused_openings(current_occupied_room_locations)
	clear_tile_conflict()
#	add_areas_to_top_of_wall()
	update_allcell_bitmasks()


func check_randomroom_viability() -> void:
	var selected_randomroom_direction: String
	
	while rooms < max_rooms:
		var new_room: Node2D = select_random_from_array(HouseRooms.get_children())
		var possible_new_room_directions: Array = []
		
		if not last_room:
			# Place first room on (0,0)
			last_room_location = room_pos_start
			set_random_room(new_room, room_pos_start, last_room_location)
			last_room = new_room.duplicate()
			current_occupied_room_locations.append(last_room_location)
			continue

		for direction in last_room.openings.keys():
			if last_room.openings[direction] == true and new_room.get_connection(direction):
				possible_new_room_directions.append(direction)
		if selected_randomroom_direction:
			possible_new_room_directions.erase(last_room.mapping[selected_randomroom_direction])
				
		if possible_new_room_directions != []:
			selected_randomroom_direction = select_random_from_array(possible_new_room_directions)
			var converted_randomroom_position = location_of_value(selected_randomroom_direction)
			if (last_room_location + converted_randomroom_position) in current_occupied_room_locations:
				check_randomroom_viability()
					
			set_random_room(new_room, converted_randomroom_position, last_room_location)
			print("OCCUPIED ROOMS = ", current_occupied_room_locations)
			last_room = new_room.duplicate()
			last_room_location = converted_randomroom_position + last_room_location
			current_occupied_room_locations.append(last_room_location)


func set_random_room(random_room: Node2D, random_room_location: Vector2, _last_room_location: Vector2) -> void:
	var random_room_template := select_random_from_array(random_room.get_node("Templates").get_children()) as Node2D
	var random_room_floor := random_room.get_node("Floor") as TileMap
	var random_room_walls := random_room_template.get_node("Walls") as TileMap
	var random_room_area := random_room_template.get_node("Areas") as TileMap
	var random_room_indexes := random_room_template.get_node("Indexes") as TileMap
	
	print("ROOM = ", random_room.get_name())
	print("ROOM POSITION CALC = ", last_room_location, " + ", random_room_location, "=", last_room_location + random_room_location)
	
	copy_tilemap(Walls, random_room_walls, (random_room_location + last_room_location))
	copy_tilemap(Floor, random_room_floor, (random_room_location + last_room_location))
	copy_tilemap(Areas, random_room_area, (random_room_location + last_room_location))
	copy_tilemap(Indexes,random_room_indexes, (random_room_location + last_room_location))
	
	copy_nodes(Walls, random_room_template.get_node("Props"), Walls.map_to_world(random_room_location + last_room_location))
	rooms += 1


func check_extent_of_shape() -> void:
	while shapes < max_shapes:
		var random_shape: Node2D = select_random_from_array(HouseShapes.get_children())
		var random_shape_width: int = random_shape.shape_width
		var random_shape_height: int = random_shape.shape_height
		var possible_shape_locations: Array = []
		
		for cell in Areas.get_used_cells():
			var shape_footprint: Array = get_tiles_in_rectangle(cell, random_shape_width, random_shape_height)
			if shape_footprint_is_empty(shape_footprint):
				possible_shape_locations.append(cell)
	
		# Selects a random shape location if there is at least 1 viable location
		if not possible_shape_locations.empty():
			var selected_shape_location = select_random_from_array(possible_shape_locations)
			set_shape(random_shape, selected_shape_location)

func shape_footprint_is_empty(shape_footprint: Array) -> bool:
	for cell in shape_footprint:
		if Areas.get_cellv(cell) == -1 or Walls.get_cellv(cell) != -1:
			return false
	return true

func set_shape(random_shape: Node2D, selected_shape_location: Vector2) -> void:
	var random_shape_walls := random_shape.get_node("Walls") as TileMap
	# Sets the shape in Walls
	copy_tilemap(Walls, random_shape_walls, selected_shape_location)
	shapes += 1

func fill_outer_walls() -> void:
	var perimiter_cells: Array = []
	for _cycles in range(0,2):
		for cell in Floor.get_used_cells():
			if Floor.get_cell(cell.x - 1, cell.y) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x - 1 * index, cell.y))
					
			if Floor.get_cell(cell.x + 1, cell.y) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x + 1 * index, cell.y))
					
			if Floor.get_cell(cell.x, cell.y - 1) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x, cell.y - 1 * index))
					
			if Floor.get_cell(cell.x, cell.y + 1) == -1:
				for index in range(1,21):
					perimiter_cells.append(Vector2(cell.x, cell.y + 1 * index))
					
		for cell in perimiter_cells:
			Floor.set_cell(cell.x, cell.y, floor_tile_id, 
			false, false, false, Walls.get_cell_autotile_coord(cell.x, cell.y))
			Walls.set_cell(cell.x, cell.y, walls_tile_id, 
			false, false, false, Walls.get_cell_autotile_coord(cell.x, cell.y))


func clear_tile_conflict() -> void:
	for cell in Walls.get_used_cells():
		if Walls.get_cellv(cell) == front_walls_tile_id or Walls.get_cellv(cell) == walls_tile_id:
			# Clear cells in Area used in Walls
			Areas.set_cell(cell.x, cell.y, -1)
			# Clear cells in Indexes used in Walls
			if Indexes.get_cellv(cell) != spawn_index_tile_id:
				Indexes.set_cell(cell.x, cell.y, -1)

# FIXME: Not used
#func clear_spawn_zone(spawn_zone: Array) -> void:
#	for cell in spawn_zone:
#		if Areas.get_cellv(cell) == -1:
#			# If index tile is not equal to a player spawn tile
#			if Indexes.get_cellv(cell) != spawn_index_tile_id:
#				Indexes.set_cell(cell.x, cell.y, -1)

func copy_nodes(recipient_node: Node2D, donor_node: Node2D, node_offset: Vector2) -> void:
	for node in donor_node.get_children():
		var node_copy = node.duplicate()
		recipient_node.add_child(node_copy)
		node_copy.set_global_position(node_copy.get_global_position() + node_offset)


func add_areas_to_top_of_wall():
	for cell in Walls.get_used_cells_by_id(walls_tile_id):
		if Walls.get_cellv(cell + Vector2(0,-1)) == -1 or Walls.get_cellv(cell + Vector2(0,-1)) == wall_shadow_tile_id:
			Areas.set_cellv(cell, Areas.get_cellv(cell + Vector2(0,-1)))

func update_allcell_bitmasks() -> void:
	for cell in Walls.get_used_cells():
		Walls.update_bitmask_area(cell)

func check_unused_openings(current_occupied_room_locations: Array) -> void:
	var top_connections: Array = [Vector2(2,0), Vector2(11,0), Vector2(20,0)]
	var side_connections: Array = [Vector2(0,11), Vector2(22,11)]
	
	for cell in current_occupied_room_locations:
		for _cell in top_connections:
			if Walls.get_cellv(cell + _cell + Vector2(0,-1)) != -1 and Walls.get_cellv(cell + _cell) == -1:
				set_connection_end((cell + _cell) + Vector2(-1,0), TopConnectionEnd)
				
			if Walls.get_cellv(cell + _cell + Vector2(-2,3)) == wall_shadow_tile_id:
				Walls.set_cell((cell.x + _cell.x + -2), (cell.y + _cell.y + 3), wall_shadow_tile_id, false, false, false, Vector2(2,0))
				
			if Walls.get_cellv(cell + _cell + Vector2(2,3)) == wall_shadow_tile_id:
				Walls.set_cell((cell.x + _cell.x + 2), (cell.y + _cell.y + 3), wall_shadow_tile_id, false, false, false, Vector2(2,0))
				
			#Set areas based on touching area
			Areas.set_cellv(cell + _cell + Vector2(-1,3), Areas.get_cellv(cell + _cell + Vector2(0,4)))
			Areas.set_cellv(cell + _cell + Vector2(0,3), Areas.get_cellv(cell + _cell + Vector2(0,4)))
			Areas.set_cellv(cell + _cell + Vector2(1,3), Areas.get_cellv(cell + _cell + Vector2(0,4)))
				
	for cell in current_occupied_room_locations:
		for _cell in side_connections:
			if Walls.get_cellv(cell + _cell + Vector2(-1,0)) != -1 and Walls.get_cellv(cell + _cell) == -1:
				set_connection_end((cell + _cell) + Vector2(0,-4), L_SideConnectionEnd)
				
				# Set area based on touching area
				Areas.set_cellv(cell + _cell + Vector2(0,-1), Areas.get_cellv(cell + _cell))
				
				
			if Walls.get_cellv(cell + _cell + Vector2(1,0)) != -1 and Walls.get_cellv(cell + _cell) == -1:
				set_connection_end((cell + _cell) + Vector2(0,-4), R_SideConnectionEnd)
				
				# Set area based on touching area
				Areas.set_cellv(cell + _cell + Vector2(0,-1), Areas.get_cellv(cell + _cell))
				

func set_connection_end(unused_opening_location: Vector2, ConnectionEnd: TileMap) -> void:
	copy_tilemap(Walls, ConnectionEnd, unused_opening_location)
	for cell in ConnectionEnd.get_used_cells():
		# Clear Area cells in connection end
		Areas.set_cell(unused_opening_location.x + cell.x, unused_opening_location.y + cell.y, -1)


func get_tiles_in_rect_centre(node_pos: Vector2, rect_width: int, rect_height: int) -> Array:
	# Rect sides must be of uneven numbers
	var rect_tiles: Array = []
	var top_left: Vector2 = node_pos - (Vector2(floor(rect_width / 2), floor(rect_height / 2)))
	var bottom_right: Vector2 = node_pos + (Vector2(floor(rect_width / 2), floor(rect_height / 2))) 
	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			rect_tiles.append(Vector2(x, y))
	return rect_tiles

func get_tiles_in_rectangle(top_left: Vector2, rect_width: int, rect_height: int) -> Array:
	var rect_tiles = []
	var bottom_right = top_left + Vector2(rect_width, rect_height)
	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			rect_tiles.append(Vector2(x, y))
	return rect_tiles

func place_props() -> void:
	for cell in Walls.get_used_cells_by_id(front_walls_tile_id):
		pass

func place_loot() -> void:
	var loot_tile_array: Array = Indexes.get_used_cells_by_id(loot_index_tile_id)
	var random_loot_positions: Array = select_random_node_positions(loot_tile_array, max_containers)
	place_nodes_in_tilemap(Container_DropTable, random_loot_positions, Vector2(0,0))

func place_enemies() -> void:
#	var enemy_tile_array = Indexes.get_used_cells_by_id(enemy_index_tile_id)
	var enemy_tile_array: Array = Areas.get_used_cells_by_id(area_tile_id).duplicate()
	for cell in spawn_zone:
		if enemy_tile_array.has(cell):
			enemy_tile_array.erase(cell)
			
	var random_enemy_positions: Array = select_random_node_positions(enemy_tile_array, max_enemies)
	place_nodes_in_tilemap(Enemies_DropTable, random_enemy_positions, Vector2(7.99, 8.01))

func place_nodes_in_tilemap(DropTable: Resource, node_positions: Array, position_offset: Vector2) -> void:
	for i in range(0, node_positions.size()):
		var node_packedscene: PackedScene = select_item_from_drop_table(DropTable)
		var node = node_packedscene.instance()
		var tilepos: Vector2 = Walls.map_to_world(node_positions[i])
		node.set_position(tilepos + position_offset)
		Walls.add_child(node)
		Indexes.set_cellv(node_positions[i], -1)
		
func place_player_spawn() -> void:
	var spawn_tile_array: Array = Indexes.get_used_cells_by_id(spawn_index_tile_id)
	var random_spawn_position: Vector2 = select_random_spawn_position(spawn_tile_array)
	var tilepos: Vector2 = Walls.map_to_world(random_spawn_position)
	place_door(random_spawn_position, tilepos)
	Player.set_position(tilepos + Vector2(23,-8))
	Player.get_node("AnimationTree").set("parameters/Idle/blend_position", Vector2(0,-0.1))
	for i in range(0, spawn_tile_array.size()):
		Indexes.set_cell(spawn_tile_array[i].x, spawn_tile_array[i].y, -1)


func place_door(random_spawn_position: Vector2, tilepos: Vector2) -> void:
	var door = Door_Scene.instance()
	Walls.set_cell(random_spawn_position.x, random_spawn_position.y, -1)
	Walls.set_cell(random_spawn_position.x + 1 , random_spawn_position.y, -1)
	Walls.set_cell(random_spawn_position.x + 2 , random_spawn_position.y, -1)
	Walls.add_child(door)
	door.set_position(tilepos)
	place_spawn_zone(door)


func place_spawn_zone(door: Node2D) -> void:
	# Position offset to compensate so the zone isn't in the wall
	var spawn_zone_width: int = 15
	var spawn_zone_height: int = 8
	spawn_zone = get_tiles_in_rect_centre(
		Walls.world_to_map(door.position) - 
		Vector2(-1,ceil(spawn_zone_height/2) + 1), spawn_zone_width, spawn_zone_height)
	
	for cell in spawn_zone:
		if Indexes.get_cellv(cell) != -1:
			Indexes.set_cell(cell.x, cell.y, -1)


func location_of_value(converted_randomroom_location: String) -> Vector2:
	var locations: Dictionary = {
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


func copy_tilemap(RecipientMap: TileMap, DonorMap: TileMap, placement_position: Vector2) -> void:
	for cell in DonorMap.get_used_cells():
		RecipientMap.set_cell(cell.x + placement_position.x, 
		cell.y + placement_position.y, DonorMap.get_cellv(cell), 
		false, false, false, DonorMap.get_cell_autotile_coord(cell.x, cell.y))

func select_random_from_array(array: Array):
	array.shuffle()
	return array.pop_front()

func select_item_from_drop_table(drop_table_def) -> Resource:
	var drop_table = drop_table_def.DropTable
	var total_drop_chance = 0
	var cumulative_drop_chance = 0
	
	for drop_table_entry in drop_table:
		total_drop_chance += drop_table_entry.DropRate
		
	var rng = randi() % total_drop_chance
	for drop_table_entry in drop_table:
		cumulative_drop_chance += drop_table_entry.DropRate
#		if the RNG is <= item cumulated total_drop_chance then drop that item
		if rng <= cumulative_drop_chance:
			return drop_table_entry.Item
	return null

func select_random_node_positions(node_tile_array: Array, max_nodes: int) -> Array:
	var node_positions: Array = []
	if node_tile_array.size() < max_nodes:
		max_nodes = node_tile_array.size()
	for _items in range(0, max_nodes):
		node_tile_array.shuffle()
		if node_tile_array[0] != null:
			node_positions.append(node_tile_array.pop_front())
	return node_positions


func select_random_spawn_position(spawn_tile_array: Array) -> Vector2:
	var player_spawn: Vector2
	var possible_player_spawns: Array = []
	for tile in spawn_tile_array:
		if player_spawn == null:
			player_spawn = tile
		if tile.y > player_spawn.y:
			player_spawn = tile
	for tile in spawn_tile_array:
		if player_spawn.y - tile.y <= 7:
			possible_player_spawns.append(tile)
	possible_player_spawns.append(player_spawn)
	
	return select_random_from_array(possible_player_spawns)
	
