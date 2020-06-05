extends StaticBody2D

class_name Pickable_Item

var more_than_one = false
var can_pickup = false
export (Resource) var item_def
onready var PickUpArea = $PickUpArea

func _ready():
	# Connect signals
	PickUpArea.connect("area_entered", self, "_on_PickUpArea_area_entered")
	PickUpArea.connect("area_exited", self, "_on_PickUpArea_area_exited")
	

func _process(_delta):
	if not item_def:
		return
	if can_pickup == true:
		if Input.is_action_just_pressed("key_e"):
			Events.emit_signal("item_picked_up", item_def)
			queue_free()

func _on_PickUpArea_area_entered(area):
	if area.get_name() == "PlayerPickupArea":
		can_pickup = true
		$GrabSprite.visible = true
		

func _on_PickUpArea_area_exited(area):
	if area.get_name() == "PlayerPickupArea":
		can_pickup = false
		$GrabSprite.visible = false

