extends StaticBody2D

signal player_entered_woodpickup_area
onready var player = get_node("../Player")


func _on_PickUpArea_body_entered(body):
	if body.get_name() =="Player":
		$GrabSprite.visible = true
		emit_signal("player_entered_woodpickup_area")

func _on_PickUpArea_body_exited(body):
	if body.get_name() =="Player":
		$GrabSprite.visible = false


func _on_Player_wood_picked_up():
	print("kaas")
	queue_free()
