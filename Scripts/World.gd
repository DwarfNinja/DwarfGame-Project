extends Node2D

const PLAYERGHOST_SCENE = preload("res://Scenes/PlayerGhostSprite.tscn")

onready var PlayerGhostSprite = $PlayerGhostSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("target_entered_sight",self, "_on_target_entered_sight")
	Events.connect("target_exited_sight",self, "_on_target_exited_sight")


func _on_target_exited_sight(last_known_targetposition):
	var playerghost_instance = PLAYERGHOST_SCENE.instance()
	playerghost_instance.set_position(last_known_targetposition)
	add_child(playerghost_instance)


func _on_target_entered_sight(last_known_targetposition):
	if PlayerGhostSprite == null:
		return
	PlayerGhostSprite.queue_free()
