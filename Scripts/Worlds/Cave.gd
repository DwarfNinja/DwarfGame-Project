extends Node2D

const TAXKNIGHT_SCENE = preload("res://Scenes/KinematicBodies/TaxKnight.tscn")

var TaxKnight_instanced = false

func _ready():
	$YSort/Player.global_position = $PlayerPosition.global_position
	Events.connect("taxtimer_is_25_percent", self, "_on_taxtimer_25_percent")
	Events.connect("taxtimer_restarted", self, "_on_taxtimer_restarted")
	
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
