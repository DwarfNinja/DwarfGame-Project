extends StaticBody2D

class_name Craftable_Item

var can_interact = false
export (Resource) var item_def
onready var InteractArea = $InteractArea
onready var CraftableSprite = get_node(str(item_def.item_name.capitalize()) + "Sprite")


func _ready():
	# Connect signals
	InteractArea.connect("area_entered", self, "_on_InteractArea_area_entered")
	InteractArea.connect("area_exited", self, "_on_InteractArea_area_exited")


func _process(_delta):
	if can_interact == true:
		if Input.is_action_just_pressed("key_e"):
			interact()

func _on_InteractArea_area_entered(area):
	can_interact = true
	CraftableSprite.material.set_shader_param("outline_color", Color(240,240,240,255))
		

func _on_InteractArea_area_exited(area):
	can_interact = false
	CraftableSprite.material.set_shader_param("outline_color", Color(240,240,240,0))

func interact():
	# Declared in the specific craftable_item
	pass
