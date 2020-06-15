extends StaticBody2D

onready var HouseScene = "res://Scenes/House.tscn"

func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		get_tree().change_scene(HouseScene)
		Events.emit_signal("exited_cave")


# Remove the current level
#var level = root.get_node("Level")
#root.remove_child(level)
#level.call_deferred("free")

# Add the next level
#var next_level_resource = load("res://path/to/scene.tscn)
#var next_level = next_level_resource.instance()
#root.add_child(next_level)
