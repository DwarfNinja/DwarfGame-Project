extends KinematicBody2D

onready var VisionConeArea = $VisionConeArea

onready var DetectionTimer = $DetectionTimer
onready var RoamingIdleDurationTimer = $RoamingIdleDurationTimer
onready var ReactionTimer = $ReactionTimer
onready var RayCastN1 = $VisionConeArea/RayCast2DN1
onready var RayCastN2 = $VisionConeArea/RayCast2DN2

const ACCELERATION = 300
const MAX_SPEED = 40
const FRICTION = 300
var velocity = Vector2.ZERO

var can_see_target = false
var state
var states = ['idle', 'roam', 'search', 'chase']

enum{
	IDLE,
	ROAM,
	SEARCH,
	CHASE
	}
	
var random_roamcell
var raycast_invertion = 1
var full_rotation_check = 0
var collided_with_object = false
var target_detected = false
var reached_target_position = false
var direction
var last_known_playerposition
var spawned_cell

var path


func _ready():
	randomize()
	
	DetectionTimer.connect("timeout", self, "_on_DetectionTimer_timeout")
	RoamingIdleDurationTimer.connect("timeout", self, "_on_RoamingIdleDurationTimer_timeout")
	ReactionTimer.connect("timeout", self, "_on_ReactionTimer_timeout")
	
	spawned_cell = self.global_position
	choose_random_state([ROAM])

func _process(_delta):
	print(path)
	
func idle():
	state = IDLE
	
func roam():
	state = ROAM
	get_random_roamcell()
	print("ROAMCELL",random_roamcell)
#	$Timer.start()
#	get_navpath(random_roamcell)
#	print("PATH",path)
	

func choose_random_state(state_list):
	state_list.shuffle()
	call(states[state_list.pop_front()])
#	return state_list.pop_front()

func get_navpath(target_cell):
	var villager_id = self
	Events.emit_signal("request_navpath", villager_id, target_cell)
	
func get_random_roamcell():
	var villager_id = self
	Events.emit_signal("request_roamcell", villager_id)

func _on_RoamingIdleDurationTimer_timeout():
	choose_random_state([IDLE, ROAM])


func _on_Timer_timeout():
	get_navpath(random_roamcell)
