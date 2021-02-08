extends Node2D

const TAXKNIGHT_SCENE = preload("res://Scenes/KinematicBodies/TaxKnight.tscn")
const PLAYER_SCENE = preload("res://Scenes/KinematicBodies/Player.tscn")

onready var Player = $YSort/Player
onready var TileSelector = $Objects/TileSelector

var TaxKnight_instanced = false

func _ready():
	randomize()
#	$YSort/Player.global_position = $PlayerPosition.global_position
	Events.connect("taxtimer_is_25_percent", self, "_on_taxtimer_25_percent")
	Events.connect("taxtimer_restarted", self, "_on_taxtimer_restarted")
	GameManager.connect("cave_scene_saved", self, "_on_cave_scene_saved")
	GameManager.connect("cave_scene_loaded", self, "_on_cave_scene_loaded")
	Player.connect("update_tileselector", self, "_on_update_tileselector")
	
	
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
#	$YSort/Player/PlayerCamera.current = false
	$CaveCamera.current = true 

func _on_update_tileselector(raycast_position, item_in_selected_slot, item_is_selected):
	if item_is_selected == true:
		if item_in_selected_slot:
			TileSelector.visible = true
			TileSelector.global_position = $Objects.map_to_world($Objects.world_to_map(raycast_position))
	else:
		TileSelector.visible = false
	
