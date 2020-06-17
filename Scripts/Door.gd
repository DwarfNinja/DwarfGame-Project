extends StaticBody2D

onready var WorldScene = "res://Scenes/World.tscn"

func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		get_tree().change_scene(WorldScene)
#		Events.emit_signal("exited_cave")
