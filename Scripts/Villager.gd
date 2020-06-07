extends KinematicBody2D


const ACCELERATION = 300
const MAX_SPEED = 40
const FRICTION = 300
var velocity = Vector2.ZERO

onready var DetectionArea = $DetectionArea

enum{
	IDLE,
	SEARCH,
	ROAM,
	CHASE
}


var detect_radius = 250
var target = null
var hit_pos = []
var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)

var can_see_player = false
var state = IDLE

func _ready():
	# Craftingtable signals
	DetectionArea.connect("body_entered", self, "_on_DetectionArea_body_entered")
	DetectionArea.connect("body_exited", self, "_on_DetectionArea_body_exited")
	
func _physics_process(delta):

	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		SEARCH:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			DetectionArea.rotation += 0.02
			seek_player()
			
		ROAM:
			pass
		
		CHASE:
			if target != null:
				aim_raycast()
#				var direction = (target.global_position - global_position).normalized()
#				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
#				DetectionArea.rotation = direction.angle()
				
			else:
				state = SEARCH
				
	velocity = move_and_slide(velocity)
	
func _process(delta):
	draw_circle(Vector2(), detect_radius, vis_color)
	if target != null:
		draw_circle((hit_pos - position).rotated(-rotation), 5, laser_color)
		draw_line(Vector2(), (hit_pos - position).rotated(-rotation), laser_color)
	
func seek_player():
	if can_see_player == true:
		state = CHASE

func aim_raycast():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, target.position, [self])#4th is collision mask)
	if result != null:
		hit_pos = result.position
		if result.collider.name == "Player":
			rotation = (target.position - position).angle()

		
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front

func _on_DetectionArea_body_entered(body):
	if body.get_name() == "Player":
		target = body
		can_see_player = true

func _on_DetectionArea_body_exited(body):
	if body.get_name() == "Player":
		target = null
		can_see_player = false
