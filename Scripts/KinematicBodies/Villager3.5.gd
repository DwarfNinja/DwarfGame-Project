extends AI_Object

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

var state
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
	
	choose_random_state(["Idle", "Roam"])
 

func _process(_delta):
	aim_raycasts()
	update()
	print(state)

func _physics_process(delta):
	visioncone_direction = Vector2(cos(VisionConeArea.rotation), sin(VisionConeArea.rotation))
	match state:
		"Idle":
			if RayCastN1.is_colliding():
				raycast_invertion = -1
			elif RayCastN2.is_colliding():
				raycast_invertion = 1
			
			if can_see_target == true:
				detect()
				
			VisionConeArea.rotation += (0.01 * raycast_invertion)
			
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			
		"Roam":
			if not random_roamcell:
				get_random_roamcell()
				
			match roam_state:
				"Roam_to_randomcell":
					set_target(random_roamcell)
					move_along_path(delta)
					if reached_endof_path == true:
						RoamDelayTimer.start()
						call("Idle")
						
				"Roam_to_spawncell":
					set_target(spawn_position)
					move_along_path(delta)
					if reached_endof_path == true:
						RoamDelayTimer.start()
						call("Idle")
						
			if can_see_target == true:
				detect()
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

			visioncone_direction = visioncone_direction.slerp(velocity.normalized(), 0.1) #where factor is 0.0 - 1.0
			VisionConeArea.rotation = visioncone_direction.angle()
			
		"Search":
			StateDurationTimer.stop()
			
			set_target(last_known_playerposition)
			move_along_path(delta)
			
			if reached_endof_path == true:
				if full_rotation_check < 2*PI:
					VisionConeArea.rotation += 0.02
					full_rotation_check += 0.02

				elif full_rotation_check >= 2*PI:
					choose_random_state(["Idle", "Roam"])
					full_rotation_check = 0
			else:
				visioncone_direction = visioncone_direction.slerp(velocity.normalized(), 0.1) #where factor is 0.0 - 1.0
				VisionConeArea.rotation = visioncone_direction.angle()
				
			if can_see_target == true:
				call("Chase")


		"Chase":
			StateDurationTimer.stop()
			
			if can_see_target == true:
				chase_target(delta)
#				ReactionTimer.stop()
				
			elif can_see_target == false:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
				if ReactionTimer.is_stopped():
					ReactionTimer.start()
				
			visioncone_direction = visioncone_direction.slerp(velocity.normalized(), 0.6) #where factor is 0.0 - 1.0
			VisionConeArea.rotation = visioncone_direction.angle()

func Idle():
	state = "Idle"

func Roam():
	state = "Roam"
	get_random_roamcell()
	
func Search():
	Events.emit_signal("update_lastknown_playerposition", last_known_playerposition)
	state = "Search"

func Chase():
	state = "Chase"


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
		call("Chase")

func _on_ReactionTimer_timeout():
	call("Search")

func _on_RoamDelayTimer_timeout():
	if roam_state == "Roam_to_randomcell":
		roam_state = "Roam_to_spawncell"
		
	elif roam_state == "Roam_to_spawncell":
		roam_state = "Roam_to_randomcell"
	call("Roam")


func _on_StateDurationTimer_timeout():
	if state == "Idle" or state == "Roam" and reached_endof_path == true:
		choose_random_state(["Idle", "Roam"])
		StateDurationTimer.wait_time = rand_range(8, 30)
		StateDurationTimer.start()

func choose_random_state(state_list):
	state_list.shuffle()
	var new_state = state_list.pop_front()
	call(new_state)


# FOR DEBUG PURPOSES
func _draw():
#	var laser_color = Color(1.0, .329, .298)
	
#	if player_in_visioncone:
#		for hit in hit_pos:
#			draw_circle((hit - position).rotated(-rotation), 1, laser_color)
#			draw_line(VisionConeArea.position, (hit - position).rotated(-rotation), laser_color)
	
#	for point in get_parent().get_node("PathContainer").get_children():
#			get_parent().get_node("PathContainer").remove_child(point)
#			point.queue_free()
	
	if state == "Roam":
		for point in path.size():
			if point > 1:
	#			print(path[0].distance_to(path[1]))
				if (path[0].distance_to(path[1])) > 9:
					var pathstep = PathNode.instance()
					pathstep.position = path[point]
					get_parent().get_node("PathContainer").add_child(pathstep)

#	for point in range(0, path.size() - 1):
#		draw_circle(path[0], 1, laser_color)
#		draw_circle(path[-1], 1, laser_color)
#		draw_line(path[point], path[point + 1] , laser_color)
