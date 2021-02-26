extends Node2D

const TAXKNIGHT_SCENE = preload("res://Scenes/Interactables/TaxKnight.tscn")
const PLAYER_SCENE = preload("res://Scenes/KinematicBodies/Player.tscn")
const ITEM_SCENE = preload("res://Scenes/Items/Item.tscn")
const TILEPOSITION_OFFSET = Vector2(0,1)

onready var Player = $YSort/Player
onready var PlayerPosition2D = $YSort/Player.get_node("PlayerInteractArea/Position2D")
onready var MapCoordOfPlayerPosition2D = $Floor.world_to_map(PlayerPosition2D.global_position)
onready var TileSelector = $YSort/TileSelector

var TaxKnight_instanced = false
var occupied_tiles = []

func _ready():
	randomize()
#	$YSort/Player.global_position = $PlayerPosition.global_position
	Events.connect("taxtimer_is_25_percent", self, "_on_taxtimer_25_percent")
	Events.connect("taxtimer_restarted", self, "_on_taxtimer_restarted")
	GameManager.connect("cave_scene_saved", self, "_on_cave_scene_saved")
	GameManager.connect("cave_scene_loaded", self, "_on_cave_scene_loaded")
	Events.connect("place_object", self, "_on_place_object")
	Events.connect("drop_item", self, "_on_drop_item")
	
func _process(_delta):
	if Player:
		MapCoordOfPlayerPosition2D = $Floor.world_to_map(PlayerPosition2D.global_position)
		update_tileselector()
		

func _on_taxtimer_25_percent():
	if TaxKnight_instanced == false:
		var taxknight_instance = TAXKNIGHT_SCENE.instance()
		taxknight_instance.set_position(get_node("TaxKnightPosition").get_global_position())
		get_node("YSort").add_child(taxknight_instance)
		TaxKnight_instanced = true

func _on_taxtimer_restarted():
	if TaxKnight_instanced == true:
		get_node("YSort/TaxKnight").queue_free()
		TaxKnight_instanced = false

func _on_cave_scene_saved():
	$YSort/Player.queue_free()

func _on_cave_scene_loaded():
	var player_scene_instance = PLAYER_SCENE.instance()
	get_tree().get_root().get_node("Cave/YSort").add_child(player_scene_instance)
	player_scene_instance.set_position(get_tree().get_root().get_node("Cave/PlayerPosition").get_global_position())
	player_scene_instance.set_owner(get_tree().get_root().get_node("Cave"))

func update_tileselector():
	var selected_item = Player.Inventory.selected_item
	if selected_item != null:
		TileSelector.visible = true
		TileSelector.global_position = $Floor.map_to_world($Floor.world_to_map(PlayerPosition2D.global_position)) + Vector2(8,8)
	else:
		TileSelector.visible = false

func _on_place_object(selected_item):
	if is_tile_empty(MapCoordOfPlayerPosition2D + TILEPOSITION_OFFSET):
		var selected_item_scene_instance = selected_item.packedscene.instance()
		selected_item_scene_instance.set_global_position($Floor.map_to_world(MapCoordOfPlayerPosition2D + TILEPOSITION_OFFSET))
		$YSort.add_child(selected_item_scene_instance)
		for x in range(selected_item.footprint.x):
			for y in range(selected_item.footprint.y):
				occupied_tiles.append(Vector2(MapCoordOfPlayerPosition2D.x + x, MapCoordOfPlayerPosition2D.y + y) + TILEPOSITION_OFFSET)
		Events.emit_signal("remove_item", selected_item)
	else:
		print("CANT PLACE ITEM!")

func _on_drop_item(selected_item):
	var item_scene_instance = ITEM_SCENE.instance()
	item_scene_instance.item_def = selected_item
	item_scene_instance.set_global_position(Player.global_position)
	item_scene_instance.play_drop_animation()
	$YSort.add_child(item_scene_instance)
	Events.emit_signal("remove_item", selected_item)
	
func is_tile_empty(tile):
	if occupied_tiles.has(tile):
		return false
	else:
		return true
