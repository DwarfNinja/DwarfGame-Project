extends StaticBody2D

signal player_entered_woodpickup_area
onready var player = get_node("../Player")


func _ready():
	#Connect Signals
	player.connect("wood_picked_up", self, "_on_wood_picked_up")

func _process(delta):
	pass

func _on_PickUpArea_body_entered(body):
	if body.get_name() =="Player":
		$GrabSprite.visible = true
		emit_signal("player_entered_woodpickup_area")

func _on_PickUpArea_body_exited(body):
	$GrabSprite.visible = false


func _on_wood_picked_up():
	queue_free()

