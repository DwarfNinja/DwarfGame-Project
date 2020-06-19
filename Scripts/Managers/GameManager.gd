extends Node

const WOOD_SCENE = preload("res://Scenes/Resources/WoodenLogs.tscn")
const IRON_SCENE = preload("res://Scenes/Resources/Iron.tscn")
const MININGRIG_SCENE = preload("res://Scenes/Craftables/MiningRig.tscn")
const FORGE_SCENE = preload("res://Scenes/Craftables/Forge.tscn")

onready var HouseScene = "res://Scenes/House.tscn"
onready var packed_cave_scene = load("res://Scenes/Packed_Cave.tscn")

var temp_scene = "res://Scenes/House.tscn"
var saved_scene

func _ready():
	Events.connect("exited_cave", self, "_on_exited_cave")
	Events.connect("entered_cave", self, "_on_entered_cave")
	Events.connect("place_item", self, "_on_place_item")

func _process(delta):
	pass

func _on_place_item(selected_item):
	var item_scene_instance = get((selected_item.item_name).to_upper() + "_SCENE").instance()
	item_scene_instance.set_position(get_tree().get_root().get_node("Cave/YSort/Player/PlayerPickupArea/Position2D").get_global_position())
	get_tree().get_root().get_node("Cave/YSort").add_child(item_scene_instance)
	item_scene_instance.set_owner(get_tree().get_root().get_node("Cave"))

func switch_scene(temp_scene):
	# save scene and remove it from the tree
	if saved_scene == null:
		saved_scene = get_tree().get_current_scene()
	get_tree().get_root().remove_child(saved_scene)
	# instance and add temporary scene as current scene
	var new_scene = load(temp_scene).instance()
	get_tree().get_root().add_child(new_scene)
	get_tree().set_current_scene(new_scene)

func load_scene():
	if saved_scene != null:
		# free temporary scene
#		get_tree().get_current_scene().queue_free()
		# add saved scene back to the tree
		get_tree().get_root().add_child(saved_scene)
		get_tree().set_current_scene(get_tree().get_root().get_node("Cave"))
		get_tree().get_root().get_node("House").queue_free()
#		saved_scene = null


func _on_exited_cave():
	switch_scene(temp_scene)
#	pack_current_scene()
#	get_tree().change_scene(HouseScene)

func _on_entered_cave():
	load_scene()
#	load_packed_scene()
#	get_tree().get_root().get_node("House").queue_free()


func pack_current_scene():
	packed_cave_scene.pack(get_tree().get_current_scene())
	ResourceSaver.save("res://Scenes/Packed_Cave.tscn", packed_cave_scene)
	get_tree().get_root().get_node("Cave").queue_free()

func load_packed_scene():
	# Change scene to packed_cave_scene
	get_tree().change_scene("res://Scenes/Packed_Cave.tscn")


#-----------------------------------------------------------------------------


#onready var HouseScene = "res://Scenes/House.tscn"
#
#func _ready():
#	Events.connect("exited_cave", self, "_on_exited_cave")
#	Events.connect("entered_cave", self, "_on_entered_cave")
#
#func _process(delta):
#	if Input.is_action_just_pressed("ui_up"):
#		_on_exited_cave()
#
#
#func pack_current_scene():
#	var packed_scene = PackedScene.new()
#	packed_scene.pack(get_tree().get_current_scene())
#	ResourceSaver.save("res://packed_cave.tscn", packed_scene)
#	get_tree().get_root().get_node("Cave").queue_free()
#
#func load_packed_scene():
#	# Load the PackedScene resource
#	var packed_scene = load("res://packed_cave.tscn")
#	# Instance the scene
#	var my_scene = packed_scene.instance()
#	get_tree().get_root().add_child(my_scene)
##	get_tree().change_scene(packed_scene)
#
#func _on_exited_cave():
#	pack_current_scene()
#	get_tree().change_scene(HouseScene)
#
#func _on_entered_cave():
#	load_packed_scene()
#	get_tree().get_root().get_node("House").queue_free()
#
#

#var item_scene_instance = get((selected_item.item_name).to_upper() + "_SCENE").instance()
#			get_parent().add_child(item_scene_instance)
