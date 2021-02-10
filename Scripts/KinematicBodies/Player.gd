extends KinematicBody2D

# Movement variables
const ACCELERATION = 800
const MAX_SPEED = 80
const FRICTION = 800 #was 600
var velocity = Vector2.ZERO

var can_move = true

# Inventory varaibles
const WOOD_SCENE = preload("res://Scenes/Resources/Wood.tscn")
const IRON_SCENE = preload("res://Scenes/Resources/Iron.tscn")
const MININGRIG_SCENE = preload("res://Scenes/Interactables/MiningRig.tscn")
const FORGE_SCENE = preload("res://Scenes/Interactables/Forge.tscn")
var selected_item = null

var scent_trail = []

export (bool) var static_camera = false
var area_in_pickuparea = false

onready var PlayerSprite = $PlayerSprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var PlayerInteractArea = $PlayerInteractArea
onready var PlayerInteractPosition2D = $PlayerInteractArea/Position2D
onready var PlayerPickupArea = $PlayerPickupArea

onready var animationState = animationTree.get("parameters/playback")

func _ready():
	# ___________________Connect Signals___________________
	#__Internal Signals__
	PlayerPickupArea.connect("body_entered", self, "_on_PlayerPickupArea_body_entered")
	
	#__External Signals__
	# Craftingtable signals
	Events.connect("entered_craftingtable", self, "_on_entered_craftingtable")
	Events.connect("exited_craftingtable", self, "_on_exited_craftingtable")
	# Forge signals
	Events.connect("entered_forge", self, "_on_entered_forge")
	Events.connect("exited_forge", self, "_on_exited_forge")
	
	$PlayerCamera.current = static_camera

func _process(_delta):
	pass

func _physics_process(delta):
	if is_visible_in_tree():
		var input_vector = Vector2.ZERO 
		if can_move == true:
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
		if PlayerSprite.frame >= 8 and PlayerSprite.frame <= 15:
			PlayerInteractArea.rotation_degrees = 90 #LEFT
		if PlayerSprite.frame >= 16 and PlayerSprite.frame <= 23:
			PlayerInteractArea.rotation_degrees = 180 #UP
		if PlayerSprite.frame >= 24 and PlayerSprite.frame <= 31:
			PlayerInteractArea.rotation_degrees = 0 #DOWN


func _on_PlayerPickupArea_body_entered(body):
	if HUD.InventoryBar.can_fit_in_inventory(body.item_def):
		Events.emit_signal("item_picked_up", body.item_def)
		body.queue_free()

func _on_entered_craftingtable():
	can_move = false
	
func _on_exited_craftingtable():
	can_move = true
	
func _on_entered_forge(_current_opened_forge):
	can_move = false

func _on_exited_forge():
	can_move = true

