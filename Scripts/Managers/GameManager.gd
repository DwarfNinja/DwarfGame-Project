extends Node

const WOOD_SCENE = preload("res://Scenes/Resources/WoodenLogs.tscn")
const IRON_SCENE = preload("res://Scenes/Resources/Iron.tscn")
const MININGRIG_SCENE = preload("res://Scenes/Craftables/MiningRig.tscn")
const FORGE_SCENE = preload("res://Scenes/Craftables/Forge.tscn")
const HOUSE_SCENE = preload("res://Scenes/House/House.tscn")

var saved_cave_scene 

signal cave_scene_saved
signal cave_scene_loaded


func _ready():
	Events.connect("exited_cave", self, "_on_exited_cave")
	Events.connect("entered_cave", self, "_on_entered_cave")
	Events.connect("place_item", self, "_on_place_item")


func _on_place_item(selected_item):
	var current_scene = str(get_tree().get_current_scene().get_name())
	var item_scene_instance = get((selected_item.item_name).to_upper() + "_SCENE").instance()
	item_scene_instance.set_position(get_tree().get_root().get_node(current_scene + "/YSort/Player/PlayerPickupArea/Position2D").get_global_position())
	get_tree().get_root().get_node(current_scene + "/YSort").add_child(item_scene_instance)
	item_scene_instance.set_owner(get_tree().get_root().get_node(current_scene))


func _on_exited_cave():
	# Saving Cave Scene and instancing House Scene
	switch_scene()

func _on_entered_cave():
	# Loading Cave and freeing House Scene
	load_scene()


func switch_scene():
	# save cave scene and remove it from the tree
	emit_signal("cave_scene_saved")
	saved_cave_scene = get_tree().get_root().get_node("Cave")
	get_tree().get_root().remove_child(saved_cave_scene)
	# instance and add house_scene as current scene
	var house_scene_instance = HOUSE_SCENE.instance()
	get_tree().get_root().add_child(house_scene_instance)
	get_tree().set_current_scene(house_scene_instance)

func load_scene():
	if not get_tree().get_root().has_node("Cave"):
		# free current scene
		get_tree().get_root().add_child(saved_cave_scene)
		get_tree().set_current_scene(saved_cave_scene)
		
		# add saved scene back to the tree
	if get_tree().get_current_scene() == saved_cave_scene:
		get_tree().get_root().get_node("House").queue_free()
		emit_signal("cave_scene_loaded")
	else: 
		load_scene()


