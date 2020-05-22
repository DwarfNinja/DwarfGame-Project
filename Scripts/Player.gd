extends KinematicBody2D

# Movement variables
const ACCELERATION = 800
const MAX_SPEED = 80
const FRICTION = 600
var velocity = Vector2.ZERO

# Inventory varaibles
#-----------------


onready var PlayerSprite = $PlayerSprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var PickupArea = $Pickup_Area

onready var animationState = animationTree.get("parameters/playback")
#onready var woodenlogs = get_parent().get_node("WoodenLogs")


func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("key_right") - Input.get_action_strength("key_left")
	input_vector.y = Input.get_action_strength("key_down") - Input.get_action_strength("key_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	

	velocity = move_and_slide(velocity)
	
	if PlayerSprite.frame >= 0 and PlayerSprite.frame <= 7:
		PickupArea.position = Vector2(19, -5) #RIGHT
	if PlayerSprite.frame >= 8 and PlayerSprite.frame <= 15:
		PickupArea.position = Vector2(-19, -5) #LEFT
	if PlayerSprite.frame >= 16 and PlayerSprite.frame <= 23:
		PickupArea.position = Vector2(0, -26) #UP
	if PlayerSprite.frame >= 24 and PlayerSprite.frame <= 31:
		PickupArea.position = Vector2(0, 14) #DOWN
	

	
	
		
		
		
		
	
#	if input_vector.y > 0:
#		itemPicker.position = Vector2(0, 14) #DOWN
#	elif input_vector.y < 0:
#		itemPicker.position = Vector2(0, -26) #UP
#	if input_vector.x > 0:
#		itemPicker.position = Vector2(19, -5) #RIGHT
#	elif input_vector.x < 0:
#		itemPicker.position = Vector2(-19, -5) #LEFT
#
#	print(input_vector)
		
	
	
#	var playback = $AnimationTree.get("parameters/playback")
#	var animation = playback.get_current_node().get("animation")
#	print(animation)
#	if animation == "IdleDown" or animation == "RunDown":
#		itemPicker.position = Vector2(0, 16)
		
