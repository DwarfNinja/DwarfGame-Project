extends TextureRect

onready var LockpickRotAnchor = $LockpickRotAnchor
onready var LockpickPosAnchor = $LockCylinder/LockpickPosAnchor
onready var LockCylinder = $LockCylinder
var current_angle = 0
var random_unlock_angle = get_random_unlock_angle()
var lockpick_broken = false
var closest_distance = calculate_closest_half()
var possible_turn_radius = calculate_possible_turn_radius()
var difficulty_modifier = 5
var lockpick_health = 50

var difficulty_dic = {
	"EASY": 10,
	"MEDIUM": 5,
	"HARD": 2
}

func _ready() -> void:
	randomize()
	
func _physics_process(delta: float) -> void:
	if can_receive_input():
		LockpickRotAnchor.rect_global_position = LockpickPosAnchor.rect_global_position
		rotate_lockpick()
		closest_distance = calculate_closest_half()
		possible_turn_radius = calculate_possible_turn_radius()
		
		if Input.is_action_pressed("key_up"):
			turn_cylinder()
		elif LockCylinder.rect_rotation > 0:
			LockCylinder.rect_rotation -= 1
		
	if Input.is_action_just_pressed("key_f"):
		lockpick_health = 50
		lockpick_broken = false
		$AnimationPlayer.play("RESET")
		
func rotate_lockpick():
	if (LockpickRotAnchor.rect_global_position.distance_to(get_global_mouse_position())  > 2):
		var angle_to_mouse = (LockpickRotAnchor.rect_global_position - get_global_mouse_position())
		LockpickRotAnchor.set_rotation(lerp_angle(LockpickRotAnchor.get_rotation(), angle_to_mouse.angle(), 0.2))
		
		current_angle = round(rad2deg(angle_to_mouse.angle()))
		current_angle = current_angle if current_angle < 0 else current_angle + 360
		
func turn_cylinder():
	if LockCylinder.rect_rotation < min(possible_turn_radius + difficulty_modifier, 89.9):
		LockCylinder.rect_rotation += 2
	else:
		if can_receive_input():
			damage_lockpick()
	

func get_random_unlock_angle():
	return round(rand_range(-180, 180))
	
func lock_is_unlocked(): 
	if LockCylinder.rect_rotation >= 89.9:
		return true
	return false

func calculate_closest_half():
	var first_half = abs(current_angle - random_unlock_angle)
	var second_half = abs(random_unlock_angle + (360 - current_angle))
	return min(first_half, second_half)

func calculate_possible_turn_radius():
	var angle_percentage = (closest_distance / 180) * 100
	var flipped_angle_percentage = 100 - angle_percentage
	return round(89.9 * (flipped_angle_percentage / 100))
	
func can_receive_input():
	if lockpick_broken == true:
		return false
	if lock_is_unlocked():
		return false
	return true

func damage_lockpick():
	$AnimationPlayer.play("Damage Lockpick")
	lockpick_health -= 1
	if lockpick_health <= 0:
		if lockpick_broken == false:
			break_lockpick()

func break_lockpick():
	$AnimationPlayer.play("Break Lockpick")
	lockpick_broken = true
	
func get_new_lockpick():
	pass
