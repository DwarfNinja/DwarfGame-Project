extends KinematicBody2D

# Movement variables
const ACCELERATION = 800
const MAX_SPEED = 60 #was 80 #was 70
const FRICTION = 800 #was 600
var velocity = Vector2.ZERO

var facing = "down"
var direction_dic = {
	"up": Vector2(0,-10),
	"down": Vector2(0,10),
	"left": Vector2(-10,0),
	"right": Vector2(10,0),
}

var can_move = true

var selected_item = null

var scent_trail = []

var area_in_pickuparea = false

onready var PlayerSprite = $PlayerSprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var PlayerInteractArea = $PlayerInteractArea
onready var PlayerPickupArea = $PlayerPickupArea
onready var Inventory = $Inventory

onready var goldcoins = preload("res://Resources/Entities/Resources/GoldCoins.tres")
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	# ___________________Connect Signals___________________
	#__Internal Signals__
	PlayerPickupArea.connect("body_entered", self, "_on_PlayerPickupArea_body_entered")
	

func _process(_delta):
	 update()

func _physics_process(delta):
	if is_visible_in_tree():
		var input_vector = Vector2.ZERO 
		if HUD.menu_open == false:
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
			PlayerInteractArea.rotation_degrees = 270 #RIGHT
			facing = "right"
		if PlayerSprite.frame >= 8 and PlayerSprite.frame <= 15:
			PlayerInteractArea.rotation_degrees = 90 #LEFT
			facing = "left"
		if PlayerSprite.frame >= 16 and PlayerSprite.frame <= 23:
			PlayerInteractArea.rotation_degrees = 180 #UP
			facing = "up"
		if PlayerSprite.frame >= 24 and PlayerSprite.frame <= 31:
			PlayerInteractArea.rotation_degrees = 0 #DOWN
			facing = "down"


func _on_PlayerPickupArea_body_entered(body):
	if Inventory.can_fit_in_inventory(body.item_def):
		Events.emit_signal("entered_pickuparea", self)
	
func _on_day_ended(tax):
	if Inventory.player_items[goldcoins] > 0:
			Inventory.player_items[goldcoins] -= tax
			HUD.update_hud_coins(Inventory.player_items[goldcoins])
	else:
		print("Game Ended")

