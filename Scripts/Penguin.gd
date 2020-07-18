extends KinematicBody2D
#const ACCELERATION = 300
#const MAX_SPEED = 40
#const FRICTION = 300
#var velocity = Vector2.ZERO
#var destination = Vector2.ZERO
#var direction
#var distance
#var collision
#
#func _ready():
#	pass
#
#func _physics_process(delta):
#	distance = global_position.distance_to(destination)
#
#	if distance > 5 and collision == null:
#		direction = (destination - global_position).normalized()
#		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
#	else:
#		velocity = Vector2.ZERO
#
#	move_and_collide(velocity * delta)
#	collision = move_and_collide(velocity * delta)
#	if collision != null:
#		is_colliding = true
#
#func _input(_event):
#	if Input.is_action_just_pressed("key_leftclick"):
#		destination = get_global_mouse_position()
#

const ACCELERATION = 300
const MAX_SPEED = 40
const FRICTION = 300
var velocity = Vector2.ZERO
var destination
var direction
var distance

func _ready():
	pass

func _physics_process(delta):
	
	if destination:
		
		distance = global_position.distance_to(destination)
		
		if distance > 5:
			direction = (destination - global_position).normalized()
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			destination = global_position
			
		velocity = move_and_slide(velocity)
		
		for slides in get_slide_count():
			var collision = get_slide_collision(slides)
			if collision != null:
				destination = global_position
	
func _input(_event):
	if Input.is_action_just_pressed("key_leftclick"):
		destination = get_global_mouse_position()
	
