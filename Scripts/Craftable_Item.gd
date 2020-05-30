extends StaticBody2D

class_name Craftable_Item

var can_interact = false
export (Resource) var item_def
onready var InteractArea = $InteractArea


func _ready():
	# Connect signals
	InteractArea.connect("area_entered", self, "_on_InteractArea_area_entered")
	InteractArea.connect("area_exited", self, "_on_InteractArea_area_exited")


func _process(_delta):
	if can_interact == true:
		if Input.is_action_just_pressed("key_e"):
			interact()


func _on_InteractArea_area_entered(area):
	if area.get_name() == "PlayerPickupArea":
		can_interact = true
		$InteractSprite.visible = true
		

func _on_InteractArea_area_exited(area):
	if area.get_name() == "PlayerPickupArea":
		can_interact = false
		$InteractSprite.visible = false

func interact():
	pass
