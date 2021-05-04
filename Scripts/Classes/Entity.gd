extends StaticBody2D
class_name Entity

export (Resource) var entity_def

onready var node_name = get_name().lstrip("@").split("@", false, 1)[0]
onready var EntitySprite = get_node(node_name + "Sprite")
onready var collisionShape2D = get_node("CollisionShape2D")

onready var facing: int = 3

enum {FRONT = 0, BACK = 1, LEFT = 2, RIGHT = 3}

func _ready() -> void:
	if not entity_def:
		EntitySprite.texture = null
		push_error("ERROR: No entity_def defined in entity " + str(self))
		get_tree().quit()
		return
		
	set_entity(entity_def)


func set_entity(_entity_def):
	entity_def = _entity_def
	EntitySprite.texture = entity_def.entity_texture
	EntitySprite.frame_coords.y = facing 
	
	var converted_rect_dimensions = get_usedrect_dimensions(get_last_frame()) / 2
	var converted_rect_position = get_usedrect_position(get_last_frame())
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
	

func get_sprite_frame(image_data) -> Image:
	var texture_size: Vector2 = EntitySprite.texture.get_size()
	var individual_frame_size: Vector2 = Vector2((texture_size.x / EntitySprite.hframes), (texture_size.y / EntitySprite.vframes))
	
	return image_data.get_rect(Rect2(Vector2(0, 0), Vector2(individual_frame_size.x, individual_frame_size.y  * (facing + 1))))

func get_first_frame() -> Image:                   
	var image_data: Image = EntitySprite.texture.get_data()
	return image_data.get_rect(Rect2(Vector2(0, 0), Vector2(48, 64)))

func get_last_frame() -> Image:
	var image_data: Image = EntitySprite.texture.get_data()
	return image_data.get_rect(Rect2(Vector2(0, 192), Vector2(48, 64)))
	
func get_usedrect_dimensions(image: Image) -> Vector2:
	var image_rect: Rect2 = image.get_used_rect()
	return image_rect.size
	# Should subtract shadow size when shadows are added

func get_usedrect_position(image: Image) -> Vector2:
	var image_rect: Rect2 = image.get_used_rect()
	return image_rect.position
	
