extends Node2D

var player
signal remove_scent

func _ready():
	$Timer.connect("timeout", self, "remove_scent")

func remove_scent():
	Events.emit_signal("remove_scent", self)
#  player.scent_trail.erase(self)
	queue_free()
