extends Node2D

export (Resource) var object_def

onready var ObjectSprite = $Distraction_Object_Sprite

func _ready() -> void:
	if not object_def:
		ObjectSprite.texture = null
		push_error("ERROR: No object_def defined in object " + str(self))
		get_tree().quit()
		return
	set_object(object_def)


func interact():
	pass
	# distract enemies

func set_object(_object_def):
	object_def = _object_def
	if not ObjectSprite:
		return
	ObjectSprite.texture = object_def.object_texture
