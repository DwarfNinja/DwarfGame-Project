extends KinematicBody2D

onready var VisionConeArea = $VisionConeArea
onready var DetectionTimer = $DetectionTimer
onready var StateDurationTimer = $StateDurationTimer
onready var ReactionTimer = $ReactionTimer
onready var RoamDelayTimer = $RoamDelayTimer
onready var PathUpdateTimer = $PathUpdateTimer
onready var RayCastN1 = $VisionConeArea/RayCast2DN1
onready var RayCastN2 = $VisionConeArea/RayCast2DN2

onready var Nav2D = get_parent().get_parent()
onready var Player = get_parent().get_node("Player")
var PathNode = preload("res://Scenes/UI/PathNode.tscn")
var PathLine = preload("res://Scenes/UI/PathLine.tscn")

const ACCELERATION = 300
const MAX_SPEED = 40
const FRICTION = 300
var direction = Vector2.ZERO
var velocity = Vector2.ZERO

#var dir = (target.global_position - global_position).normalized()

var visioncone_direction = Vector2.RIGHT
var full_rotation_check = 0

var hit_pos

var last_known_playerposition setget set_lastknown_playerposition
var updated_playerghost = false

var player_in_area
var target setget set_target
var can_see_target
var raycast_invertion = 1

var spawn_position
var random_roamcell  

var state
var roam_state = "Roam_to_randomcell"

var path = []
var reached_endof_path = true

func _ready():
	randomize()
	VisionConeArea.connect("body_entered", self, "_on_VisionConeArea_body_entered")
	VisionConeArea.connect("body_exited", self, "_on_VisionConeArea_body_exited")
	
	DetectionTimer.connect("timeout", self, "_on_DetectionTimer_timeout")
	StateDurationTimer.connect("timeout", self, "_on_StateDurationTimer_timeout")
	ReactionTimer.connect("timeout", self, "_on_ReactionTimer_timeout")
	RoamDelayTimer.connect("timeout", self, "_on_RoamDelayTimer_timeout")
#	PathUpdateTimer.connect("timeout", self, "_on_PathUpdateTimer_timeout")
	
	spawn_position = get_global_position()
	get_random_roamcell()
	instance_pathvisuals()
	
	choose_random_state(["Idle", "Roam"])
 

func _process(_delta):
	aim_raycasts()
	update()

func _physics_process(delta):
	visioncone_direction = Vector2(cos(VisionConeArea.rotation), sin(VisionConeArea.rotation))
#	print(state)
#	print(roam_state)
#	print(reached_endof_path)

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
				chase_player(delta)
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

func Search():
	Events.emit_signal("update_playerghost", last_known_playerposition)
	state = "Search"

func Chase():
	state = "Chase"

func set_target(new_target):
	if target:
		if new_target != target:
			target = new_target
			update_path()
		if !path:
			update_path()
	else:
		target = new_target
		update_path()

func set_lastknown_playerposition(new_playerposition):
	if last_known_playerposition:
		if new_playerposition != last_known_playerposition:
			last_known_playerposition = new_playerposition
	else:
		last_known_playerposition = new_playerposition

func update_path():
	if PathUpdateTimer.is_stopped():
		path = Nav2D.get_simple_path(global_position, target, false)
		PathUpdateTimer.start()
#		if path:
#			if target == random_roamcell or target == spawn_position:
#				Nav2D.get_node("Walls/PathContainer/RoamPath_" + get_name()).points = PoolVector2Array(path)
#				Nav2D.get_node("Walls/PathContainer/StartPoint_" + get_name()).global_position = path[0]
#				Nav2D.get_node("Walls/PathContainer/EndPoint_" + get_name()).global_position = path[-1]
		

func aim_raycasts():
	if player_in_area:
		hit_pos = []
		var space_state = get_world_2d().direct_space_state
		var target_extents = Vector2(Player.get_node("CollisionShape2D").shape.radius, Player.get_node("CollisionShape2D").shape.height) - Vector2(5, 5)
		var nw = Player.position - target_extents
		var se = Player.position + target_extents
		var ne = Player.position + Vector2(target_extents.x, -target_extents.y)
		var sw = Player.position + Vector2(-target_extents.x, target_extents.y)
		for pos in [Player.position, nw, ne, se, sw]:
			var result = space_state.intersect_ray(VisionConeArea.global_position, pos, [self], 0b100001)
			if result:
				hit_pos.append(result.position)
				if result.collider.name == "Player":
					can_see_target = true
					set_lastknown_playerposition(Player.global_position)
				else:
					can_see_target = false
	else:
		can_see_target = false

func move_along_path(delta):
	var starting_point = get_global_position()
	var move_distance = MAX_SPEED * delta
	
#	if path.size() > 0:
	for point in range(path.size()):
		reached_endof_path = false
		var distance_to_next_point = starting_point.distance_to(path[0])
		if move_distance <= distance_to_next_point:
			var move_rotation = get_angle_to(starting_point.linear_interpolate(path[0], move_distance / distance_to_next_point))
			direction = Vector2(cos(move_rotation), sin(move_rotation))
#			velocity = Vector2(MAX_SPEED, 0).rotated(move_rotation)
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			move_and_slide(velocity)
			break
		move_distance -= distance_to_next_point
		starting_point = path[0]
		path.remove(0)
	
	if path.size() == 0:
		reached_endof_path = true

func chase_player(delta):
	var distance = global_position.distance_to(Player.global_position)
	
	if distance > 3:
		direction = (Player.global_position - global_position).normalized()
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		move_and_slide(velocity)

func detect():
	if can_see_target == true:
		visioncone_direction = visioncone_direction.slerp((Player.global_position - global_position).normalized(), 0.3) #where factor is 0.0 - 1.0
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
	else:
		StateDurationTimer.wait_time = rand_range(8, 30)
		StateDurationTimer.start()

func choose_random_state(state_list):
	state_list.shuffle()
	var new_state = state_list.pop_front()
	call(new_state)

func _on_VisionConeArea_body_entered(body):
	if body.get_name() == "Player":
		player_in_area = true

func _on_VisionConeArea_body_exited(body):
	if body.get_name() == "Player":
		player_in_area = false

func instance_pathvisuals():
	var NewLine = PathLine.instance()
#	NewLine.set_name("RoamPath_" + get_name())
#	Nav2D.get_node("Walls/PathContainer").add_child(NewLine)
#
#	var Startpoint = PathNode.instance()
#	Startpoint.set_name("StartPoint_" + get_name())
#	Nav2D.get_node("Walls/PathContainer").add_child(Startpoint)
#	var Endpoint = PathNode.instance()
#	Endpoint.set_name("EndPoint_" + get_name())
#	Nav2D.get_node("Walls/PathContainer").add_child(Endpoint)
	

# FOR DEBUG PURPOSES
func _draw():
	var laser_color = Color(1.0, .329, .298)
	
#	if player_in_area:
#		for hit in hit_pos:
#			draw_circle((hit - position).rotated(-rotation), 1, laser_color)
#			draw_line(VisionConeArea.position, (hit - position).rotated(-rotation), laser_color)
	
	for point in get_parent().get_node("PathContainer").get_children():
			get_parent().get_node("PathContainer").remove_child(point)
			point.queue_free()
			
	for point in path.size():
		if point > 1:
#			print(path[0].distance_to(path[1]))
			if (path[0].distance_to(path[1])) > 9:
				var pathstep = PathNode.instance()
				pathstep.position = path[point]
				get_parent().get_node("PathContainer").add_child(pathstep)
#
#	for point in range(0, path.size() - 1):
#		draw_circle(path[0], 1, laser_color)
#		draw_circle(path[-1], 1, laser_color)
#		draw_line(path[point], path[point + 1] , laser_color)
