extends Node2D

const TAXKNIGHT_SCENE = preload("res://Scenes/KinematicBodies/TaxKnight.tscn")
const PLAYER_SCENE = preload("res://Scenes/KinematicBodies/Player.tscn")

var TaxKnight_instanced = false

func _ready():
#	$YSort/Player.global_position = $PlayerPosition.global_position
	Events.connect("taxtimer_is_25_percent", self, "_on_taxtimer_25_percent")
	Events.connect("taxtimer_restarted", self, "_on_taxtimer_restarted")
	GameManager.connect("cave_scene_saved", self, "_on_cave_scene_saved")
	GameManager.connect("cave_scene_loaded", self, "_on_cave_scene_loaded")
	
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
#	$YSort/Player.global_position = $PlayerPosition.global_position
#	$YSort/Player/AnimationTree.set("parameters/Run/blend_position", Vector2(0, 1))
#	$YSort/Player/AnimationTree.set("parameters/Idle/blend_position", Vector2(0, 1))
	
func _on_cave_scene_loaded():
	var player_scene_instance = PLAYER_SCENE.instance()
	get_tree().get_root().get_node("Cave/YSort").add_child(player_scene_instance)
	player_scene_instance.set_position(get_tree().get_root().get_node("Cave/PlayerPosition").get_global_position())
	player_scene_instance.set_owner(get_tree().get_root().get_node("Cave"))
#	$YSort/Player/PlayerCamera.current = false
	$CaveCamera.current = true
