extends KinematicBody2D

onready var DetectionArea = $DetectionArea

const ACCELERATION = 300
const MAX_SPEED = 40
const FRICTION = 300
var velocity = Vector2.ZERO

var can_see_target
var state = IDLE

enum{
	IDLE,
	SEARCH,
	ROAM,
	CHASE
}

#onready var shape = $DetectionArea/CollisionPolygon2D
onready var DetectionTimer = $DetectionTimer
onready var SearchTimer = $SearchTimer

var last_known_targetposition
var laser_color = Color(1.0, .329, .298)
var target
var hit_pos

func _ready():
	DetectionArea.connect("body_entered", self, "_on_DetectionArea_body_entered")
	DetectionArea.connect("body_exited", self, "_on_DetectionArea_body_exited")
	
	DetectionTimer.connect("timeout", self, "_on_DetectionTimer_timeout")
	SearchTimer.connect("timeout", self, "_on_SearchTimer_timeout")
	


func _physics_process(delta):
	update()
	if target:
		aim_raycast()
		
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

		SEARCH:
			if round(global_position.x) + round(global_position.y) == round(last_known_targetposition.x) + round(last_known_targetposition.y):
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
				var curent_detectionarea_rotation = DetectionArea.rotation
				DetectionArea.rotation += 0.02
				if SearchTimer.time_left == 0:
					SearchTimer.start()
			
		ROAM:
			print("Villager is Roaming")
		
		CHASE:
			if target:
				if can_see_target == true:
					var direction = (target.global_position - global_position).normalized()
					velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
					DetectionArea.rotation = direction.angle()
					last_known_targetposition = target.global_position
				else:
					state = SEARCH
					velocity = velocity.move_toward(last_known_targetposition * MAX_SPEED, ACCELERATION  * delta)
					print("BOOOM")
			else:
				state = SEARCH
				velocity = velocity.move_toward(last_known_targetposition * MAX_SPEED, ACCELERATION  * delta)
				print("BIIINGG")
	
	
	velocity = move_and_slide(velocity)

func _process(delta):
#	print(SearchTimer.time_left)
#	print(round(global_position.x), round(global_position.y))
#	if last_known_targetposition:
#		print(round(last_known_targetposition.x), round(last_known_targetposition.y))
	if target:
		if can_see_target == true and DetectionTimer.time_left == 0:
			print("PAPAPAPAP")
			DetectionTimer.start()
		


func aim_raycast():
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
			else:
				can_see_target = false

func _on_DetectionTimer_timeout():
	state = CHASE
	
func _on_SearchTimer_timeout():
	pass

func _on_DetectionArea_body_entered(body):
	if body.get_name() == "Player":
		target = body

func _on_DetectionArea_body_exited(body):
	if body.get_name() == "Player":
		target = null



# FOR DEBUG PURPOSES
func _draw():
	if target:
		for hit in hit_pos:
			draw_circle((hit - position).rotated(-rotation), 1, laser_color)
			draw_line(Vector2(), (hit - position).rotated(-rotation), laser_color)
