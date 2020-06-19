extends StaticBody2D

onready var CaveScene = "res://Scenes/Cave.tscn"

func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
#		Events.emit_signal("entered_cave")
		Events.call_deferred('emit_signal', 'entered_cave')
