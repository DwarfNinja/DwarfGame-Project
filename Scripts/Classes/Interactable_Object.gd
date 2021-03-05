extends StaticBody2D

class_name Interactable_Object

var can_interact = false
onready var InteractArea = $InteractArea
onready var node_name = get_name().lstrip("@").split("@", false, 1)[0]
onready var InteractableSprite = get_node(node_name + "Sprite")


func _ready():
	# Connect signals
	InteractArea.connect("area_entered", self, "_on_InteractArea_area_entered")
	InteractArea.connect("area_exited", self, "_on_InteractArea_area_exited")


func _process(_delta):
	if can_interact == true:
		if Input.is_action_just_pressed("key_e"):
			interact()

func _on_InteractArea_area_entered(_area):
	can_interact = true
	InteractableSprite.material.set_shader_param("outline_color", Color(240,240,240,255))
		

func _on_InteractArea_area_exited(_area):
	can_interact = false
	InteractableSprite.material.set_shader_param("outline_color", Color(240,240,240,0))

func interact():
	# Declared in the specific Craftable_Object
	pass

