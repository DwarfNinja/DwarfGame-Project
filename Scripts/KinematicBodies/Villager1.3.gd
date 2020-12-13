extends KinematicBody2D

onready var VisionConeArea = $VisionConeArea

onready var DetectionTimer = $DetectionTimer
onready var RoamingIdleDurationTimer = $RoamingIdleDurationTimer
onready var ReactionTimer = $ReactionTimer


const ACCELERATION = 300
const MAX_SPEED = 40
const FRICTION = 300
var velocity = Vector2.ZERO

var random_roamcell
var can_see_target = false
var state

enum{
	IDLE,
	ROAM,
	SEARCH,
	CHASE
	}

var full_rotation_check = 0
var collided_with_object = false
var target_detected = false
var reached_target_position = false
var direction
var last_known_playerposition
var laser_color = Color(1.0, .329, .298)
var target
var hit_pos
var points
var spawned_cell

func _ready():
	randomize()
	VisionConeArea.connect("body_entered", self, "_on_VisionConeArea_body_entered")
	VisionConeArea.connect("body_exited", self, "_on_VisionConeArea_body_exited")
	
	DetectionTimer.connect("timeout", self, "_on_DetectionTimer_timeout")
	RoamingIdleDurationTimer.connect("timeout", self, "_on_RoamingIdleDurationTimer_timeout")
	ReactionTimer.connect("timeout", self, "_on_ReactionTimer_timeout")
	

	
	spawned_cell = self.global_position
#	$PlayerGhost.set_as_toplevel(true)
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
#			rotate_vision_cone()
			
			
			
			
		ROAM:
#			print("Villager is Roaming")

			if random_roamcell == null:
				get_random_roamcell()
#			print(self.get_instance_id(), "=", random_roamcell)
			move_to_target_location(delta, random_roamcell)
			
			if can_see_target == true and DetectionTimer.is_stopped():
				DetectionTimer.start()
				
			if can_see_target == false:
				DetectionTimer.stop()
				
			if RoamingIdleDurationTimer.is_stopped():
				RoamingIdleDurationTimer.start()
				
				
		SEARCH:
#			print("Villager is Searching")

			move_to_target_location(delta, last_known_playerposition)
			
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
				move_to_target_location(delta, last_known_playerposition)
				VisionConeArea.rotation = direction.angle()
				update_playerghost_sprite()
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
				
			if can_see_target == false and ReactionTimer.is_stopped():
				ReactionTimer.start()
				update_playerghost_sprite()
			else:
				update_playerghost_sprite()
				
			if RoamingIdleDurationTimer.time_left > 0:
				RoamingIdleDurationTimer.stop()

	velocity = move_and_slide(velocity)


func _process(_delta):
	check_sight_on_target()
	

func aim_raycasts():
	hit_pos = []
	var space_state = get_world_2d().direct_space_state
	var target_extents = Vector2(target.get_node("CollisionShape2D").shape.radius, target.get_node("CollisionShape2D").shape.height) - Vector2(5, 5)
	var nw = target.position - target_extents
	var se = target.position + target_extents
	var ne = target.position + Vector2(target_extents.x, -target_extents.y)
	var sw = target.position + Vector2(-target_extents.x, target_extents.y)
	for pos in [target.position, nw, ne, se, sw]:
		var result = space_state.intersect_ray($VisionConeArea.global_position, pos, [self], collision_mask)
		if result:
			hit_pos.append(result.position)
			if result.collider.name == "Player":
				can_see_target = true
				last_known_playerposition = target.global_position
			else:
				can_see_target = false
				
				
func randomize_roamingidle_timer():
	RoamingIdleDurationTimer.wait_time = rand_range(7, 20)

func choose_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func get_vision_cone_range():
	var vision_cone_range
	var current_collision = $VisionConeRayCast2D.get_collider()
	var current_collider = current_collision
	var new_collider
	if $VisionConeRayCast2D.is_colliding():
		if "TileMap" in current_collision.get_name():
			new_collider = current_collision
	else:
		new_collider = null
	if new_collider != current_collider:
		vision_cone_range.append(new_collider)
	$VisionConeRayCast2D.rotation_degrees += 1
	if vision_cone_range.size() == 2:
		return vision_cone_range
	
		
			
#func rotate_vision_cone():
#	if vision_cone_range == [] or vision_cone_range == null:
#		vision_cone_range = get_vision_cone_range()
#	print("VISIONCONERANGE", vision_cone_range)
#	var min_visioncone_range = vision_cone_range.min()
#	var max_visioncone_range = vision_cone_range.max()
	

	
func check_sight_on_target():
	if can_see_target == true and DetectionTimer.is_stopped():
		DetectionTimer.start()
				
	if can_see_target == false:
		DetectionTimer.stop()
		
func update_playerghost_sprite():
	if can_see_target == false and reached_target_position == false:
		if $PlayerGhost.visible == false:
			$PlayerGhost.global_position = last_known_playerposition
		$PlayerGhost.visible = true
	else:
		$PlayerGhost.visible = false
	
func move_to_target_location(delta, target):
	var distance = global_position.distance_to(target)
	
	if distance > 3:
		reached_target_position = false
		direction = (target - global_position).normalized()
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	else:
		reached_target_position = true
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		target = Vector2.ZERO
		
func get_random_roamcell():
	var villager_id = self.get_name()
	Events.emit_signal("request_roamcell", villager_id)

func _on_DetectionTimer_timeout():
	if can_see_target == true:
		state = CHASE
	elif can_see_target == false:
		state = SEARCH
		

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
		
# FOR DEBUG PURPOSES
func _draw():
	if target:
		for hit in hit_pos:
			draw_circle((hit - position).rotated(-rotation), 1, laser_color)
			draw_line($VisionConeArea.position, (hit - position).rotated(-rotation), laser_color)
