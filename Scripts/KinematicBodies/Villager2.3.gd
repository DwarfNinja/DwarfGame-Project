extends KinematicBody2D

onready var VisionConeArea = $VisionConeArea
onready var DetectionTimer = $DetectionTimer
onready var StateDurationTimer = $StateDurationTimer
onready var ReactionTimer = $ReactionTimer
onready var RoamDelayTimer = $RoamDelayTimer
onready var RayCastN1 = $VisionConeArea/RayCast2DN1
onready var RayCastN2 = $VisionConeArea/RayCast2DN2

onready var Player = get_parent().get_node("Player")

const ACCELERATION = 300
const MAX_SPEED = 40
const FRICTION = 300
var direction = Vector2.ZERO
var velocity = Vector2.ZERO

#var dir = (target.global_position - global_position).normalized()

var visioncone_direction = Vector2.RIGHT

var hit_pos
var scent_hit

var last_known_playerposition

var target
var can_see_target
var raycast_invertion = 1

var spawn_position
var random_roamcell  

var state
var roam_state = "Roam_to_randomcell"

var path = PoolVector2Array([])
var inverse_path = PoolVector2Array([])
var full_roam_path = []
var reached_endof_path = false
var reached_endof_inversepath = false

func _ready():
	randomize()
	VisionConeArea.connect("body_entered", self, "_on_VisionConeArea_body_entered")
	VisionConeArea.connect("body_exited", self, "_on_VisionConeArea_body_exited")
	
	DetectionTimer.connect("timeout", self, "_on_DetectionTimer_timeout")
	StateDurationTimer.connect("timeout", self, "_on_StateDurationTimer_timeout")
	ReactionTimer.connect("timeout", self, "_on_ReactionTimer_timeout")
	RoamDelayTimer.connect("timeout", self, "_on_RoamDelayTimer_timeout")
	
	spawn_position = get_global_position()
	print("spawn_position", spawn_position)
	get_random_roamcell()
	get_navpath(random_roamcell)
	choose_random_state(["Idle", "Roam"])
 

func _process(_delta):
	aim_raycasts()
	update()
		
#	if StateDurationTimer.is_stopped() and velocity == Vector2.ZERO:
#		StateDurationTimer.start()

func _physics_process(delta):
	visioncone_direction = Vector2(cos(VisionConeArea.rotation), sin(VisionConeArea.rotation))
	print(state)
	
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
			if full_roam_path == []:
				full_roam_path = [path, inverse_path]
			if path and inverse_path:
				roam_state = "Roam_to_randomcell"
			elif !path and inverse_path:
				roam_state = "Roam_to_spawncell"

			match roam_state:
				"Roam_to_randomcell":
					move_along_path()
					velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
					if reached_endof_path == true:
						RoamDelayTimer.start()
						state = "Idle"
						
				"Roam_to_spawncell":
					move_along_inversepath()
					velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
					if reached_endof_inversepath == true:
						RoamDelayTimer.start()
						state = "Idle"
						
			visioncone_direction = visioncone_direction.slerp(velocity.normalized(), 0.1) #where factor is 0.0 - 1.0
			VisionConeArea.rotation = visioncone_direction.angle()
			
			
			if can_see_target == true:
				detect()
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
				
		"Search":
			Events.emit_signal("update_playerghost", last_known_playerposition)
			get_navpath(last_known_playerposition)
			
			
		"Chase":
			if can_see_target == true:
				direction = (Player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				ReactionTimer.stop()
				
			elif can_see_target == false:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
				if ReactionTimer.is_stopped():
					ReactionTimer.start()
				
			visioncone_direction = visioncone_direction.slerp(velocity.normalized(), 0.4) #where factor is 0.0 - 1.0
			VisionConeArea.rotation = visioncone_direction.angle()
			
	
	velocity = move_and_slide(velocity)
	
	
func aim_raycasts():
	if target:
		hit_pos = []
		var space_state = get_world_2d().direct_space_state
		var target_extents = Vector2(target.get_node("CollisionShape2D").shape.radius, target.get_node("CollisionShape2D").shape.height) - Vector2(5, 5)
		var nw = target.position - target_extents
		var se = target.position + target_extents
		var ne = target.position + Vector2(target_extents.x, -target_extents.y)
		var sw = target.position + Vector2(-target_extents.x, target_extents.y)
		for pos in [target.position, nw, ne, se, sw]:
			var result = space_state.intersect_ray(VisionConeArea.global_position, pos, [self], 0b100001)
			if result:
				hit_pos.append(result.position)
				if result.collider.name == "Player":
					can_see_target = true
					last_known_playerposition = target.global_position
				else:
					can_see_target = false
	else:
		can_see_target = false

		
func move_along_path():
	if path.size() > 0:
		reached_endof_path = false
		var distance = global_position.distance_to(path[0])
		if distance > 5:
			direction = (path[0] - global_position).normalized()
		else:
			path.remove(0)
	else:
		direction = Vector2.ZERO
		reached_endof_path = true
		
		
func move_along_inversepath():
	if inverse_path.size() > 0:
		reached_endof_inversepath = false
		var distance = global_position.distance_to(inverse_path[0])
		if distance > 5:
			direction = (inverse_path[0] - global_position).normalized()
		else:
			inverse_path.remove(0)
	else:
		direction = Vector2.ZERO
		reached_endof_inversepath = true
	
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
	
func get_navpath(target):
	var villager_id = self
	Events.call_deferred("emit_signal", "request_navpath", villager_id, target)
#	Events.emit_signal("request_navpath", villager_id, target_cell)

func _on_DetectionTimer_timeout():
	state = "Chase"
		
func _on_ReactionTimer_timeout():
	state = "Search"
	
func _on_RoamDelayTimer_timeout():
	if path == PoolVector2Array([]) and inverse_path == PoolVector2Array([]):
		path = full_roam_path[0]
		inverse_path = full_roam_path[1]
		
	if roam_state == "Roam_to_randomcell":
		roam_state = "Roam_to_spawncell"
		
	elif roam_state == "Roam_to_spawncell":
		roam_state = "Roam_to_randomcell"
	state = "Roam"
	
func _on_StateDurationTimer_timeout():
	choose_random_state(["Idle", "Roam"])
	StateDurationTimer.wait_time = rand_range(8, 30)
	StateDurationTimer.start()
	
func choose_random_state(state_list):
	state_list.shuffle()
	var new_state = state_list.pop_front()
	state = new_state
	
func _on_VisionConeArea_body_entered(body):
	if body.get_name() == "Player":
		target = body
		
func _on_VisionConeArea_body_exited(body):
	if body.get_name() == "Player":
		target = null
	
# FOR DEBUG PURPOSES
func _draw():
	var laser_color = Color(1.0, .329, .298)
	if target:
		for hit in hit_pos:
			draw_circle((hit - position).rotated(-rotation), 1, laser_color)
			draw_line(VisionConeArea.position, (hit - position).rotated(-rotation), laser_color)
	if scent_hit:
		draw_circle((scent_hit - position).rotated(-rotation), 1, laser_color)
		draw_line(VisionConeArea.position, (scent_hit - position).rotated(-rotation), laser_color, 3)
