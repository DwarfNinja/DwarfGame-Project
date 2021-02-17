extends RigidBody2D

class_name Pickable_Item2

export (Resource) var item_def
onready var PickUpArea = $PickUpArea
onready var ItemSprite = $ItemSprite
onready var TrailParticles2D = $TrailParticles2D
onready var animationPlayer = $AnimationPlayer

var direction = Vector2(0,0)
var body_in_pickuparea = null

func _ready():
	# Connect signals
	PickUpArea.connect("body_entered", self, "_on_PickUpArea_body_entered")
	PickUpArea.connect("body_exited", self, "_on_PickUpArea_body_exited")
	animationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	
	if not item_def:
		ItemSprite.texture = null
		push_error("ERROR: No item_def defined in item " + str(self))
		return
	set_item(item_def)

func _integrate_forces(_state):
	if body_in_pickuparea != null:
		if HUD.InventoryBar.can_fit_in_inventory(item_def):
			direction = (global_position - body_in_pickuparea.global_position).normalized()
			apply_central_impulse(-direction * 5)

func set_item(_itemdef):
	item_def = _itemdef
	if not ItemSprite:
		return
	ItemSprite.texture = item_def.item_texture


func _on_PickUpArea_body_entered(body):
	body_in_pickuparea = body
#	TrailParticles2D.emitting = true

func _on_PickUpArea_body_exited(_body):
	body_in_pickuparea = null
#	TrailParticles2D.emitting = false


func _on_AnimationPlayer_animation_finished(anim_name):
	animationPlayer.play("Hover")
