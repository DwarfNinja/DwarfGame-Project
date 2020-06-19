extends KinematicBody2D

onready var CollisionArea = $CollisionArea
onready var VisionConeArea = $VisionConeArea

onready var IdleRotationTimer = $IdleRotationTimer
onready var DetectionTimer = $DetectionTimer
onready var WaitTimer = $WaitTimer
onready var RoamingIdleDurationTimer = $RoamingIdleDurationTimer
onready var ReactionTimer = $ReactionTimer

const ACCELERATION = 300
const MAX_SPEED = 40
const FRICTION = 300
var velocity = Vector2.ZERO

var can_see_target = false
var state

enum{
	IDLE,
	SEARCH,
	ROAM,
	CHASE
}


var full_rotation_check = 0
var collided_with_object = false
var target_detected = false
var reached_target_position = false
var direction
var last_known_targetposition
var laser_color = Color(1.0, .329, .298)
var target
var hit_pos
var points

func _ready():
	randomize()
	VisionConeArea.connect("body_entered", self, "_on_VisionConeArea_body_entered")
	VisionConeArea.connect("body_exited", self, "_on_VisionConeArea_body_exited")
	CollisionArea.connect("area_entered", self, "_on_CollisionArea_area_entered")
	CollisionArea.connect("area_exited", self, "_on_CollisionArea_area_exited")
	
	DetectionTimer.connect("timeout", self, "_on_DetectionTimer_timeout")
	WaitTimer.connect("timeout", self, "_on_WaitTimer_timeout")
	RoamingIdleDurationTimer.connect("timeout", self, "_on_RoamingIdleDurationTimer_timeout")
	ReactionTimer.connect("timeout", self, "_on_ReactionTimer_timeout")
	
	$PlayerGhostSprite.set_as_toplevel(true)
	
	state = choose_random_state([IDLE, ROAM])
	randomize_roamingidle_timer()
	

func _physics_process(delta):
	update()
	if target:
		aim_raycasts()
	else:
		can_see_target = false
		
	match state:
		
		IDLE:
#			print("Villager is Idling")
			
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			if IdleRotationTimer.is_stopped():
				VisionConeArea.rotation_degrees += 45
				IdleRotationTimer.start()
				
			if can_see_target == true and DetectionTimer.is_stopped():
				DetectionTimer.start()
				
			if can_see_target == false:
				DetectionTimer.stop()
			
			if RoamingIdleDurationTimer.is_stopped():
				RoamingIdleDurationTimer.start()

		ROAM:
#			print("Villager is Roaming")
			
			if can_see_target == true and DetectionTimer.is_stopped():
				DetectionTimer.start()
			if can_see_target == false:
				DetectionTimer.stop()
				
			if RoamingIdleDurationTimer.is_stopped():
				RoamingIdleDurationTimer.start()
				

		SEARCH:
#			print("Villager is Searching")
			move_to_player_location(delta)
			
			for slides in get_slide_count():
				var collision = get_slide_collision(slides)
				# ALTERATE CODE?: if CollisionShape2D in collision.collider_shape:
				if "CollisionShape2D" or "CollisionPolygon2D" in collision.collider_shape.to_string():
					if velocity > Vector2(-1,-1) and velocity < Vector2(1,1):
						collided_with_object = true
			
			if reached_target_position == true and full_rotation_check < 2*PI:
				VisionConeArea.rotation += 0.02
				full_rotation_check += 0.02
				update_playerghost_sprite()
			
			if full_rotation_check >= 2*PI:
				state = choose_random_state([IDLE, ROAM])
				full_rotation_check = 0
				
			if can_see_target == true:
				state = CHASE
			
			if RoamingIdleDurationTimer.time_left > 0:
				RoamingIdleDurationTimer.stop()
				
		CHASE:
#			print("Villager is Chasing")
			
			if can_see_target == true:
				direction = (target.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				VisionConeArea.rotation = direction.angle()
				update_playerghost_sprite()
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
				
			if can_see_target == false and ReactionTimer.is_stopped():
				ReactionTimer.start()
				update_playerghost_sprite()
				
			if RoamingIdleDurationTimer.time_left > 0:
				RoamingIdleDurationTimer.stop()

	velocity = move_and_slide(velocity)



func _process(_delta):
	pass

func aim_raycasts():
	hit_pos = []
	var space_state = get_world_2d().direct_space_state
	var target_extents = Vector2(target.get_node('CollisionShape2D').shape.radius, target.get_node('CollisionShape2D').shape.height) - Vector2(5, 5)
	var nw = target.position - target_extents
	var se = target.position + target_extents
	var ne = target.position + Vector2(target_extents.x, -target_extents.y)
	var sw = target.position + Vector2(-target_extents.x, target_extents.y)
	for pos in [target.position, nw, ne, se, sw]:
		var result = space_state.intersect_ray(position, pos, [self], collision_mask)
		if result:
			hit_pos.append(result.position)
			if result.collider.name == "Player":
				can_see_target = true
				last_known_targetposition = target.global_position
			else:
				can_see_target = false
				
func randomize_roamingidle_timer():
	RoamingIdleDurationTimer.wait_time = rand_range(7, 20)
	print("RoamingIdleDurationTimer Wait Time is Randomized")

func choose_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func update_playerghost_sprite():
	if can_see_target == false and reached_target_position == false:
		$PlayerGhostSprite.global_position = last_known_targetposition
		$PlayerGhostSprite.visible = true
	else:
		$PlayerGhostSprite.visible = false
	
	
# !!!!!!!!!!!!!!!!!!!!!!!!! CAN CLEAN UP CODE !!!!!!!!!!!!!!!!!!!!!!!!!
func move_to_player_location(delta):
	if reached_target_position == true:
		velocity = Vector2(0,0)
		
	if global_position.round() == last_known_targetposition.round() or collided_with_object == true:
		velocity = Vector2(0,0)
		reached_target_position = true
		
	if reached_target_position == false:
		var direction_to_last_know_targeposition = (last_known_targetposition - global_position).normalized()
		velocity = velocity.move_toward(direction_to_last_know_targeposition * MAX_SPEED, ACCELERATION  * delta)
		
		
func _on_DetectionTimer_timeout():
	if can_see_target == true:
		state = CHASE
	elif can_see_target == false:
		state = SEARCH
		
	
func _on_WaitTimer_timeout():
	pass

func _on_ReactionTimer_timeout():
	state = SEARCH
	
func _on_RoamingIdleDurationTimer_timeout():
	state = choose_random_state([IDLE, ROAM])
	randomize_roamingidle_timer()
	RoamingIdleDurationTimer.start()

	
func _on_VisionConeArea_body_entered(body):
	if body.get_name() == "Player":
		target = body

func _on_VisionConeArea_body_exited(body):
	if body.get_name() == "Player":
		target = null

func _on_CollisionArea_area_entered(area):
	if area.get_name() == "PlayerGhostArea":
		reached_target_position = true

func _on_CollisionArea_area_exited(area):
	if area.get_name() == "PlayerGhostArea":
		reached_target_position = false


# FOR DEBUG PURPOSES
func _draw():
	if target:
		for hit in hit_pos:
			draw_circle((hit - position).rotated(-rotation), 1, laser_color)
			draw_line(Vector2(), (hit - position).rotated(-rotation), laser_color)
