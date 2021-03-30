extends Node

const HOUSE_SCENE = preload("res://Scenes/Worlds/House/House.tscn")

var saved_cave_scene 

var tax = 200
var seconds = 0
var day_ended = true
var total_day_realtime_sec = 900
var time_speed = 1.5


signal cave_scene_saved()
signal cave_scene_loaded()


func _ready():
	Events.connect("exited_cave", self, "_on_exited_cave")
	Events.connect("entered_cave", self, "_on_entered_cave")

func _process(delta):
	if day_ended == false:
		run_time(delta)
	
		if seconds >= total_day_realtime_sec * 0.75:
			Events.emit_signal("day_ending")

func _on_exited_cave():
	# Saving Cave Scene and instancing House Scene
	switch_scene()

func _on_entered_cave():
	# Loading Cave and freeing House Scene
	load_scene()

#TODO: change to be dynamic, take Scene as argument
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

func run_time(delta):
	var minutes = seconds/60
	
	if seconds == total_day_realtime_sec:
		end_day()
		
	seconds += delta * time_speed
	HUD.DayTimeLabel.text = ("%02d : %02d" % [int(minutes + 7) % 24 , int(seconds) % 60])

func end_day():
	day_ended = true
	Events.emit_signal("day_ended", tax)
	
func start_day():
	seconds = 0
	day_ended = false
	Events.emit_signal("day_started")
