extends RigidBody2D

class_name Pickable_Item

export (Resource) var item_def
onready var ItemSprite = $ItemSprite
onready var TrailParticles2D = $TrailParticles2D
onready var animationPlayer = $AnimationPlayer
onready var collisionShape2D = $CollisionShape2D
onready var TweenNode = $Tween

var direction = Vector2(0,0)
var target = null
var targetpos

func _ready():
	# Connect signals
	animationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	TweenNode.connect("tween_all_completed", self, "_on_TweenNode_tween_all_completed")
	Events.connect("entered_pickuparea", self, "_on_entered_pickuparea")
	
	if not item_def:
		ItemSprite.texture = null
		push_error("ERROR: No item_def defined in item " + str(self))
		return
	set_item(item_def)

func _integrate_forces(_state):
	if target:
		if HUD.InventoryBar.can_fit_in_inventory(item_def):
			direction = (global_position - target.global_position).normalized()
			apply_central_impulse(-direction * 5)
			
		if global_position.distance_to(target.global_position) < 15:
			if HUD.InventoryBar.can_fit_in_inventory(item_def):
				Events.emit_signal("item_picked_up", item_def)
				queue_free()
			

func set_item(_itemdef):
	item_def = _itemdef
	if not ItemSprite:
		return
	ItemSprite.texture = item_def.item_texture


func _on_entered_pickuparea(_target):
	target = _target
#	TrailParticles2D.emitting = true

func _on_exited_external_playerPickupArea(_body):
	target = null
#	TrailParticles2D.emitting = false


func play_drop_animation(direction):
	collisionShape2D.disabled = true
	targetpos = global_position + direction
	var ITEM_JUMP_HEIGHT = 32
	
	TweenNode.interpolate_property(self, "global_position:x", global_position.x, targetpos.x, 0.5)
	TweenNode.interpolate_property(self, "global_position:y", global_position.y, targetpos.y - ITEM_JUMP_HEIGHT, 0.25)
	TweenNode.interpolate_property(self, "global_position:y", targetpos.y - ITEM_JUMP_HEIGHT, targetpos.y, 0.85, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 0.6)
	TweenNode.start()

func _on_TweenNode_tween_all_completed():
	collisionShape2D.disabled = false
