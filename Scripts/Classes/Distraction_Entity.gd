extends Interactable_Entity

onready var Distraction_Object_Sprite = $Distraction_Object_Sprite

func _ready() -> void:
	if not object_def:
		Distraction_Object_Sprite.texture = null
		push_error("ERROR: No object_def defined in object " + str(self))
		get_tree().quit()
		return
	set_object(object_def)


func interact():
	pass
	# distract enemies

func set_object(_object_def):
	object_def = _object_def
	if not Distraction_Object_Sprite:
		return
	Distraction_Object_Sprite.texture = object_def.object_texture
