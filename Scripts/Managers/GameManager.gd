extends Node

onready var HouseScene = "res://Scenes/House.tscn"

func _ready():
	Events.connect("exited_cave", self, "_on_exited_cave")
	Events.connect("entered_cave", self, "_on_entered_cave")

func pack_current_scene():
	var packed_cave_scene = load("res://Scenes/Packed_Cave.tscn")
	packed_cave_scene.pack(get_tree().get_current_scene())
	ResourceSaver.save("res://Scenes/Packed_Cave.tscn", packed_cave_scene)
	get_tree().get_root().get_node("Cave").queue_free()

func load_packed_scene():
	# Change scene to packed_cave_scene
	get_tree().change_scene("res://Scenes/Packed_Cave.tscn")

func _on_exited_cave():
	pack_current_scene()
	get_tree().change_scene(HouseScene)

func _on_entered_cave():
	load_packed_scene()
	get_tree().get_root().get_node("House").queue_free()



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
