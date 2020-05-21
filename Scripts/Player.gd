extends KinematicBody2D

# Movement variables
const ACCELERATION = 800
const MAX_SPEED = 80
const FRICTION = 600
var velocity = Vector2.ZERO

# Inventory varaibles
var can_pickup_wood = false
var wood_in_inv = 0

# Signals
signal wood_picked_up

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var woodenlogs = get_parent().get_node("WoodenLogs")


func _ready():
	#Connect Signals
	woodenlogs.connect("player_entered_woodpickup_area", self, "_on_player_entered_woodpickup_area")
	

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

func _process(delta):
	if can_pickup_wood == true:
		if Input.is_action_just_pressed("key_e"):
			wood_in_inv += 1
			emit_signal("wood_picked_up")

func _on_player_entered_woodpickup_area():
	can_pickup_wood = true
	
