extends StaticBody2D
class_name Entity

export (Resource) var entity_def

onready var node_name = get_name().lstrip("@").split("@", false, 1)[0]
onready var EntitySprite = get_node(node_name + "Sprite")
onready var collisionShape2D = get_node("CollisionShape2D")

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
	var converted_rect_dimensions = get_rect_dimensions(get_horizontal_sprite()) / 2
	var converted_rect_position = get_rect_position(get_horizontal_sprite())
	collisionShape2D.shape.extents = converted_rect_dimensions
	collisionShape2D.position = (converted_rect_position + converted_rect_dimensions) + EntitySprite.position - Vector2(24, 32)
							   
	match entity_def.type_name:
		"prop":
			EntitySprite.hframes = 1
			EntitySprite.vframes = 4
		"lootable":
			EntitySprite.hframes = 3
			EntitySprite.vframes = 1
			
		"craftable":
			return
	

func get_horizontal_sprite() -> Image:                   
	var image_data: Image = EntitySprite.texture.get_data()
	return image_data.get_rect(Rect2(Vector2(0, 0), Vector2(48, 64)))

func get_vertical_sprite() -> Image:
	var image_data: Image = EntitySprite.texture.get_data()
	return image_data.get_rect(Rect2(Vector2(0, 0), Vector2(48, 240)))
	
func get_rect_dimensions(image: Image) -> Vector2:
	var image_rect = image.get_used_rect()
	return image_rect.size
	# Should subtract shadow size when shadows are added

func get_rect_position(image: Image) -> Vector2:
	var image_rect: Rect2 = image.get_used_rect()
	return image_rect.position
	
