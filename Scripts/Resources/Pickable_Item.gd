extends StaticBody2D

class_name Pickable_Item

var more_than_one = false
var can_pickup = false
export (Resource) var item_def
onready var PickUpArea = $PickUpArea
onready var ItemSprite = get_node(str(item_def.item_name.capitalize()) + "Sprite" )
#onready var WhiteOutlineShader = preload("res://Shaders/WhiteOutlineShader.tres")

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
	print(area)
	can_pickup = true
#	ItemSprite.set_material(WhiteOutlineShader)
	ItemSprite.material.set_shader_param("outline_color", Color(240,240,240,255))
		

func _on_PickUpArea_area_exited(_area):
	can_pickup = false
#	ItemSprite.set_material(null)
	ItemSprite.material.set_shader_param("outline_color", Color(240,240,240,0))
		
