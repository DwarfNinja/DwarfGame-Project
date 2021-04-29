extends Node2D

const TAXKNIGHT_SCENE = preload("res://Scenes/Interactables/TaxKnight.tscn")
const PLAYER_SCENE = preload("res://Scenes/KinematicBodies/Player.tscn")
const ITEM_SCENE = preload("res://Scenes/Items/Item.tscn")
const TILEPOSITION_OFFSET = Vector2(0,1)

const DAY_COLOR = Color("ffffff")
const NIGHT_COLOR = Color("2d2246")


onready var Player = $YSort/Player
onready var PlayerPosition2D = $YSort/Player.get_node("PlayerInteractArea/Position2D")
onready var MapCoordOfPlayerPosition2D = $Floor.world_to_map(PlayerPosition2D.global_position)
onready var TileSelector = $YSort/TileSelector
onready var CanvasModulater = $CanvasModulate

var TaxKnight_instanced = false
var occupied_tiles = []

func _ready():
	randomize()
#	$YSort/Player.global_position = $PlayerPosition.global_position
	Events.connect("day_ending", self, "_on_day_ending")
	Events.connect("day_ended", self, "_on_day_ended")
	GameManager.connect("cave_scene_saved", self, "_on_cave_scene_saved")
	GameManager.connect("cave_scene_loaded", self, "_on_cave_scene_loaded")
	Events.connect("place_object", self, "_on_place_object")
	Events.connect("drop_item", self, "_on_drop_item")
	
func _process(_delta):
	if Player:
		MapCoordOfPlayerPosition2D = $Floor.world_to_map(PlayerPosition2D.global_position)
		update_tileselector()
	
	CanvasModulater.color = DAY_COLOR.linear_interpolate(NIGHT_COLOR,  (sin(GameManager.seconds)+1)/2)

func _on_day_ending():
	if not get_node("YSort").get_childeren().has(TAXKNIGHT_SCENE):
		var taxknight_instance = TAXKNIGHT_SCENE.instance()
		taxknight_instance.set_position(get_node("TaxKnightPosition").get_global_position())
		get_node("YSort").add_child(taxknight_instance)

func _on_day_started():
	if get_node("YSort").get_childeren().has(TAXKNIGHT_SCENE):
		get_node("YSort/TaxKnight").queue_free()

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
		var selected_item_scene = load(selected_item.scene_path)
		var selected_item_scene_instance = selected_item_scene.instance()
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
#	item_scene_instance.play_drop_animation()
	$YSort.add_child(item_scene_instance)
	Events.emit_signal("remove_item", selected_item)
	
func is_tile_empty(tile):
	if occupied_tiles.has(tile):
		return false
	else:
		return true
