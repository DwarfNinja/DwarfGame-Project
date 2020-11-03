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

var hit_pos

var last_known_playerposition

var target
var can_see_target
var raycast_invertion = 1

var spawn_position
var random_roamcell  

var state

var received_path

func _ready():
	randomize()
	VisionConeArea.connect("body_entered", self, "_on_VisionConeArea_body_entered")
	VisionConeArea.connect("body_exited", self, "_on_VisionConeArea_body_exited")
	
	DetectionTimer.connect("timeout", self, "_on_DetectionTimer_timeout")
	RoamingIdleDurationTimer.connect("timeout", self, "_on_RoamingIdleDurationTimer_timeout")
	ReactionTimer.connect("timeout", self, "_on_ReactionTimer_timeout")
	spawn_position = get_global_position()
	get_random_roamcell()
	choose_random_state(["Idle", "Roam"])

func _process(delta):
	aim_raycasts()
	update()

func _physics_process(delta):

	match state:
		"Idle":
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			VisionConeArea.rotation += (0.01 * raycast_invertion)
			
			if RayCastN1.is_colliding():
				raycast_invertion = -1
			elif RayCastN2.is_colliding():
				raycast_invertion = 1
				
		"Roam":
#			if random_roamcell:
#				get_navpath(random_roamcell)
#				print(path)
			move_along_path(delta, random_roamcell)
		"Search":
			pass
		"Chase":
			pass
	velocity = move_and_slide(velocity)
	
func Idle():
	pass
func Roam():
	pass
func Search():
	pass
func Chase():
	pass
	
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
			var result = space_state.intersect_ray($VisionConeArea.global_position, pos, [self], collision_mask)
			if result:
				hit_pos.append(result.position)
				if result.collider.name == "Player":
					can_see_target = true
					last_known_playerposition = target.global_position
				else:
					can_see_target = false
				
				
func move_along_path(delta, target_cell):
	if received_path == null:
		received_path = get_parent().get_parent().get_simple_path(global_position, target_cell, false)
	get_parent().get_parent().get_parent().get_node("Line2D").points = PoolVector2Array(received_path)
	get_parent().get_parent().get_parent().get_node("Line2D").show()
	
	if received_path.size() > 0:
		for point in range(received_path.size()):
			var distance = global_position.distance_to(received_path[0])
			print(distance)
			if distance > 10:
				var direction = (received_path[0] - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				received_path.remove(0)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)


func get_random_roamcell():
	var villager_id = self
	Events.emit_signal("request_roamcell", villager_id)

func get_navpath(target_cell):
	var villager_id = self
	Events.emit_signal("request_navpath", villager_id, target_cell)

func choose_random_state(state_list):
	state_list.shuffle()
	var new_state = state_list.pop_front()
	state = new_state
	call(new_state)

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
