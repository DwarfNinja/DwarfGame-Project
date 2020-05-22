extends StaticBody2D

var can_pickup = false
export var item_name = "stone"
export var item_count = 1

func _ready():
	pass

func _process(_delta):
	if can_pickup == true:
		if Input.is_action_just_pressed("key_e"):
			Events.emit_signal("item_picked_up", item_name, item_count)
			queue_free()
		

func _on_PickupArea_area_entered(area):
	if area.is_in_group("pickup_area"):
		can_pickup = true
		$GrabSprite.visible = true


func _on_PickupArea_area_exited(area):
	if area.get_name() == "Pickup_Area":
		can_pickup = false
		$GrabSprite.visible = false
