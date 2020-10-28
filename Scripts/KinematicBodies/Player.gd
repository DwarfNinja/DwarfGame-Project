extends KinematicBody2D

# Movement variables
const ACCELERATION = 800
const MAX_SPEED = 80
const FRICTION = 800 #was 600
var velocity = Vector2.ZERO

var can_move = true

# Inventory varaibles
var selected_item = null
const WOOD_SCENE = preload("res://Scenes/Resources/WoodenLogs.tscn")
const IRON_SCENE = preload("res://Scenes/Resources/Iron.tscn")
const MININGRIG_SCENE = preload("res://Scenes/Craftables/MiningRig.tscn")
const FORGE_SCENE = preload("res://Scenes/Craftables/Forge.tscn")

signal place_item

export (bool) var static_camera = false
var area_in_pickuparea = false

onready var PlayerSprite = $PlayerSprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var PlayerPickupArea = $PlayerPickupArea
onready var SelectedItemSprite = $PlayerPickupArea/SelectedItemSprite

onready var animationState = animationTree.get("parameters/playback")
#onready var woodenlogs = get_parent().get_node("WoodenLogs")

func _ready():
	# ___________________Connect Signals___________________
	
	Events.connect("item_selected", self, "_on_item_selected")
	# Craftingtable signals
	Events.connect("entered_craftingtable", self, "_on_entered_craftingtable")
	Events.connect("exited_craftingtable", self, "_on_exited_craftingtable")
	# Forge signals
	Events.connect("entered_forge", self, "_on_entered_forge")
	Events.connect("exited_forge", self, "_on_exited_forge")

	$PlayerCamera.current = static_camera

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
			PlayerPickupArea.position = Vector2(19, 0) #RIGHT
		if PlayerSprite.frame >= 8 and PlayerSprite.frame <= 15:
			PlayerPickupArea.position = Vector2(-19, 0) #LEFT
		if PlayerSprite.frame >= 16 and PlayerSprite.frame <= 23:
			PlayerPickupArea.position = Vector2(-0.5, -14) #UP
		if PlayerSprite.frame >= 24 and PlayerSprite.frame <= 31:
			PlayerPickupArea.position = Vector2(-0.5, 14) #DOWN
	
func _process(_delta):
	if Input.is_action_just_pressed("key_rightclick"):
		place_item()

func _on_item_selected(item_in_selected_slot):
	if item_in_selected_slot:
		SelectedItemSprite.texture = item_in_selected_slot.item_texture
		print(item_in_selected_slot.item_texture)
	else:
		SelectedItemSprite.texture = null
	selected_item = item_in_selected_slot
	
func place_item():
	if selected_item != null:
		if PlayerPickupArea.get_overlapping_bodies() == []:
			Events.emit_signal("place_item", selected_item)
			Events.emit_signal("item_placed", selected_item)
		else:
			print("CANT PLACE ITEM!")
			
func _on_entered_craftingtable():
	can_move = false
	
func _on_exited_craftingtable():
	can_move = true
	
func _on_entered_forge(_current_opened_forge):
	can_move = false

func _on_exited_forge():
	can_move = true

