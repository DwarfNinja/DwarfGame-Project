extends KinematicBody2D

class_name AI_Object

export (Resource) var ai_def
onready var node_name = get_name().lstrip("@").split("@", false, 1)[0]
onready var AISprite = get_node(node_name + "Sprite")
onready var VisionConeArea = get_node("VisionConeArea")

var direction = Vector2.ZERO
const ACCELERATION = 300
const MAX_SPEED = 20 #was 30
const FRICTION = 300
var velocity = Vector2.ZERO


var last_known_playerposition setget set_lastknown_playerposition
var target 
var targetpos setget set_target

var player_in_visioncone
var can_see_target
var hit_pos = []

var spawn_position
var random_roamcell  

var path = []
var reached_endof_path = false

func _ready():
	VisionConeArea.connect("body_entered", self, "_on_VisionConeArea_body_entered")
	VisionConeArea.connect("body_exited", self, "_on_VisionConeArea_body_exited")
	
	if not ai_def:
		AISprite.texture = null
		push_error("ERROR: No ai_def defined in AI: " + str(self))
		return
	set_ai(ai_def)



func _process(delta):
	pass
#	print(VisionConeArea.get_overlapping_bodies())
	
func set_ai(_ai_def):
	ai_def = _ai_def
	if not AISprite:
		return
	AISprite.texture = ai_def.ai_spritesheet


func set_target(new_targetpos):
	if targetpos:
		if new_targetpos != targetpos:
			targetpos = new_targetpos
			update_path()
		if !path:
			update_path()
	elif new_targetpos:
		targetpos = new_targetpos
		update_path()
	else:
		push_error("ERROR: Paramater new_targetpos is null in AI: " + str(self))


func set_lastknown_playerposition(new_playerposition):
	if last_known_playerposition:
		if new_playerposition != last_known_playerposition:
			last_known_playerposition = new_playerposition
	else:
		last_known_playerposition = new_playerposition
	Events.emit_signal("update_lastknown_playerposition", last_known_playerposition, can_see_target)

func aim_raycasts():
	if player_in_visioncone:
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
				if result.collider.name == target.get_name():
					can_see_target = true
					set_lastknown_playerposition(target.global_position)
				else:
					can_see_target = false
	else:
		can_see_target = false

func move_along_path(delta):
	var starting_point = get_global_position()
	var move_distance = MAX_SPEED * delta
	
	for _point in range(path.size()):
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

func chase_target(delta):
	if target:
		var distance = global_position.distance_to(target.global_position)
		
		if distance > 3:
			direction = (target.global_position - global_position).normalized()
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			move_and_slide(velocity)

func update_path():
#	Events.call_deferred("emit_signal", "request_navpath", self, target)
	Events.emit_signal("request_navpath", self, targetpos)
	

func _on_VisionConeArea_body_entered(body):
	if body.get_name() == "Player":
		target = body
		targetpos = body.global_position
		player_in_visioncone = true

func _on_VisionConeArea_body_exited(body):
	if body.get_name() == "Player":
		target = null
		targetpos = null
		player_in_visioncone = false
