extends KinematicBody2D

func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	look_at(mouse_pos)
