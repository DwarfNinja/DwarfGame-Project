extends AI_Body

onready var DetectionTimer = $DetectionTimer
onready var StateDurationTimer = $StateDurationTimer
onready var ReactionTimer = $ReactionTimer
onready var RoamDelayTimer = $RoamDelayTimer
onready var PathUpdateTimer = $PathUpdateTimer
onready var RayCastN1 = $VisionConeArea/RayCast2DN1
onready var RayCastN2 = $VisionConeArea/RayCast2DN2

onready var Nav2D = get_parent().get_parent()
var PathNode = preload("res://Scenes/UI/Navigation/PathNode.tscn")
var PathLine = preload("res://Scenes/UI/Navigation/PathLine.tscn")

var visioncone_direction = Vector2.RIGHT
var full_rotation_check = 0

var updated_playerghost = false

var raycast_invertion = 1

enum STATES {
	IDLE, 
	ROAM, 
	SEARCH, 
	CHASE
}

var roam_state = "Roam_to_randomcell"

func _ready():
	randomize()
	DetectionTimer.connect("timeout", self, "_on_DetectionTimer_timeout")
	StateDurationTimer.connect("timeout", self, "_on_StateDurationTimer_timeout")
	ReactionTimer.connect("timeout", self, "_on_ReactionTimer_timeout")
	RoamDelayTimer.connect("timeout", self, "_on_RoamDelayTimer_timeout")
#	PathUpdateTimer.connect("timeout", self, "_on_PathUpdateTimer_timeout")
	
	spawn_position = get_global_position()
#	instance_pathvisuals()
	
	choose_random_state([STATES.IDLE, STATES.ROAM])
 

func _process(_delta):
	aim_raycasts()
	update()

func _physics_process(delta):
	visioncone_direction = Vector2(cos(VisionConeArea.rotation), sin(VisionConeArea.rotation))
	
	match state:
		STATES.IDLE:
			if RayCastN1.is_colliding():
				raycast_invertion = -1
			elif RayCastN2.is_colliding():
				raycast_invertion = 1
			
			if can_see_target == true:
				detect()
				
			VisionConeArea.rotation += (0.01 * raycast_invertion)
			
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			
		STATES.ROAM:
			if not random_roamcell:
				get_random_roamcell()
				
			match roam_state:
				"Roam_to_randomcell":
					set_target(random_roamcell)
					move_along_path(delta)
						
				"Roam_to_spawncell":
					set_target(spawn_position)
					move_along_path(delta)
					
			if can_see_target == true:
				detect()
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
				
			if reached_endof_path == true:
				RoamDelayTimer.start()
				state = STATES.IDLE
						
			visioncone_direction = visioncone_direction.slerp(velocity.normalized(), 0.05) #where factor is 0.0 - 1.0
			VisionConeArea.rotation = visioncone_direction.angle()
			
		STATES.SEARCH:
			StateDurationTimer.stop()
			
			set_target(last_known_playerposition)
			set_lastknown_playerposition(last_known_playerposition)
			move_along_path(delta)
			
			if reached_endof_path == true:
				if full_rotation_check < 2*PI:
					VisionConeArea.rotation += 0.015
					full_rotation_check += 0.015

				elif full_rotation_check >= 2*PI:
					choose_random_state([STATES.IDLE, STATES.ROAM])
					full_rotation_check = 0
			else:
				visioncone_direction = visioncone_direction.slerp(last_known_playerposition - global_position, 0.1) #where factor is 0.0 - 1.0
				VisionConeArea.rotation = visioncone_direction.angle()
				
			if can_see_target == true:
				state = STATES.CHASE


		STATES.CHASE:
			StateDurationTimer.stop()
			
			if can_see_target == true:
				chase_target(delta)
				visioncone_direction = visioncone_direction.slerp(velocity.normalized(), 0.6) #where factor is 0.0 - 1.0
				VisionConeArea.rotation = visioncone_direction.angle()
#				ReactionTimer.stop()
				
			elif can_see_target == false:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
				if ReactionTimer.is_stopped():
					ReactionTimer.start()
				

func detect():
	if target:
		if can_see_target:
			visioncone_direction = visioncone_direction.slerp((target.global_position - global_position).normalized(), 0.3) #where factor is 0.0 - 1.0
			VisionConeArea.rotation = visioncone_direction.angle()
			if DetectionTimer.is_stopped():
				DetectionTimer.start()
		
		elif can_see_target == false:
			DetectionTimer.stop()

func get_random_roamcell():
	var villager_id = self
	Events.emit_signal("request_roamcell", villager_id)

func _on_DetectionTimer_timeout():
	if can_see_target == true:
		state = STATES.CHASE

func _on_ReactionTimer_timeout():
	state = STATES.SEARCH

func _on_RoamDelayTimer_timeout():
	if roam_state == "Roam_to_randomcell":
		roam_state = "Roam_to_spawncell"
		
	elif roam_state == "Roam_to_spawncell":
		roam_state = "Roam_to_randomcell"
	state = STATES.ROAM

func _on_StateDurationTimer_timeout():
	if state == STATES.IDLE or state == STATES.ROAM and reached_endof_path == true:
		choose_random_state([STATES.IDLE, STATES.ROAM])
		StateDurationTimer.wait_time = rand_range(8, 30)
		StateDurationTimer.start()

func choose_random_state(state_list):
	state_list.shuffle()
	state = state_list.pop_front()

# FOR DEBUG PURPOSES
#func _draw():
#	var laser_color = Color(1.0, .329, .298)

#	if player_in_visioncone:
#		for hit in hit_pos:
#			draw_circle((hit - position).rotated(-rotation), 1, laser_color)
#			draw_line(VisionConeArea.position, (hit - position).rotated(-rotation), laser_color)
#	pass
