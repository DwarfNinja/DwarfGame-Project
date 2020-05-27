extends KinematicBody2D

# Movement variables
const ACCELERATION = 800
const MAX_SPEED = 80
const FRICTION = 600
var velocity = Vector2.ZERO

# Inventory varaibles
var selected_item = null
const WOOD_SCENE = preload("res://Scenes/WoodenLogs.tscn")
const IRON_SCENE = preload("res://Scenes/Iron.tscn")

export (bool) var static_camera = false
var area_in_pickuparea = false

onready var PlayerSprite = $PlayerSprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var PickupArea = $Pickup_Area
onready var SelectedItemSprite = $Pickup_Area/SelectedItemSprite


onready var animationState = animationTree.get("parameters/playback")
#onready var woodenlogs = get_parent().get_node("WoodenLogs")

func _ready():
	# Connect Signals
	Events.connect("item_selected", self, "_on_item_selected")
	$Camera2D.current = !static_camera

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
	
func _process(_delta):
	if Input.is_action_just_pressed("key_rightclick"):
		place_item()

func _on_item_selected(item_in_selected_slot):
	if item_in_selected_slot:
		SelectedItemSprite.texture = item_in_selected_slot.item_texture
	else:
		SelectedItemSprite.texture = null
	selected_item = item_in_selected_slot
	
func place_item():
	if selected_item != null:
		if PickupArea.get_overlapping_bodies() == []:
			var item_scene_instance = get((selected_item.item_name).to_upper() + "_SCENE").instance()
			item_scene_instance.set_position(get_node("Pickup_Area/Position2D").get_global_position())
			get_parent().add_child(item_scene_instance)
			Events.emit_signal("item_placed", selected_item)
		else:
			print("CANT PLACE ITEM!")
