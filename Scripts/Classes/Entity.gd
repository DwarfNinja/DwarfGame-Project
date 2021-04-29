extends StaticBody2D
class_name Entity

export (Resource) var entity_def

onready var node_name = get_name().lstrip("@").split("@", false, 1)[0]
onready var EntitySprite = get_node(node_name + "Sprite")

func _ready() -> void:
	if not entity_def:
		EntitySprite.texture = null
		push_error("ERROR: No entity_def defined in object " + str(self))
		get_tree().quit()
		return
	set_object(entity_def)


func set_object(_object_def):
	entity_def = _object_def
	if not EntitySprite:
		return
	EntitySprite.texture = entity_def.entity_texture
	
#	match entity_def.type_name:
#
#		"lootable":
#			EntitySprite.hframes = 1
#			EntitySprite.vframes = 1
#
#		"lootable":
#			EntitySprite.hframes = 3
#			EntitySprite.vframes = 1
