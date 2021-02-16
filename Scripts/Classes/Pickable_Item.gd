extends RigidBody2D

class_name Pickable_Item

export (Resource) var item_def
onready var PickUpArea = $PickUpArea
onready var ItemSprite = get_node(item_def.item_name.capitalize() + "Sprite")
onready var TrailParticles2D = $TrailParticles2D

var direction = Vector2(0,0)
var body_in_pickuparea = null

func _ready():
	# Connect signals
	
	PickUpArea.connect("body_entered", self, "_on_PickUpArea_body_entered")
	PickUpArea.connect("body_exited", self, "_on_PickUpArea_body_exited")
	
func _process(_delta):
	if not item_def:
		print("ERROR: No item_def defined")
		return
			
func _integrate_forces(_state):
	if body_in_pickuparea != null:
		if HUD.InventoryBar.can_fit_in_inventory(item_def):
			direction = (global_position - body_in_pickuparea.global_position).normalized()
			apply_central_impulse(-direction * 5)
	
	
func _on_PickUpArea_body_entered(body):
	body_in_pickuparea = body
#	TrailParticles2D.emitting = true
	
func _on_PickUpArea_body_exited(_body):
	body_in_pickuparea = null
#	TrailParticles2D.emitting = false
