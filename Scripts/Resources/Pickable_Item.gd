extends RigidBody2D

class_name Pickable_Item

var more_than_one = false
var can_pickup = false
export (Resource) var item_def
onready var PickUpArea = $PickUpArea
onready var ItemSprite = get_node(item_def.item_name.capitalize() + "Sprite")
onready var TrailParticles2D = $TrailParticles2D

var direction = Vector2(0,0)
var body_in_pickuparea = null

func _ready():
	# Connect signals
#	PickUpArea.connect("area_entered", self, "_on_PickUpArea_area_entered")
#	PickUpArea.connect("area_exited", self, "_on_PickUpArea_area_exited")
	
	PickUpArea.connect("body_entered", self, "_on_PickUpArea_body_entered")
	PickUpArea.connect("body_exited", self, "_on_PickUpArea_body_exited")
	
func _process(_delta):
	if not item_def:
		print("ERROR: No item_def defined")
		return
	if can_pickup == true:
		if Input.is_action_just_pressed("key_e"):
			Events.emit_signal("item_picked_up", item_def)
			queue_free()
			
func _integrate_forces(_state):
	if body_in_pickuparea != null:
		direction = (global_position - body_in_pickuparea.global_position).normalized()
		apply_central_impulse(-direction * 5)
	
	
func _on_PickUpArea_body_entered(body):
	body_in_pickuparea = body
#	TrailParticles2D.emitting = true
	
func _on_PickUpArea_body_exited(_body):
	body_in_pickuparea = null
	TrailParticles2D.emitting = false
#	direction = Vector2(0,0)

#func _on_PickUpArea_area_entered(area):
#	print(area)
#	can_pickup = true
##	ItemSprite.set_material(WhiteOutlineShader)
#	ItemSprite.material.set_shader_param("outline_color", Color(240,240,240,255))
#
#
#func _on_PickUpArea_area_exited(_area):
#	can_pickup = false
##	ItemSprite.set_material(null)
#	ItemSprite.material.set_shader_param("outline_color", Color(240,240,240,0))
		
