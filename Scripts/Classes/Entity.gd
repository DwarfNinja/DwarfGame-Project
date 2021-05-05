extends StaticBody2D
class_name Entity

export (Resource) var entity_def

onready var node_name = get_name().lstrip("@").split("@", false, 1)[0]
onready var EntitySprite = get_node(node_name + "Sprite")
onready var collisionShape2D = get_node("CollisionShape2D")

onready var facing: int = 0

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
	
	match entity_def.type_name:
		"prop":
			EntitySprite.vframes = 4
			EntitySprite.hframes = 1
			set_collision_shape()
			set_entity_position()
		"lootable":
			EntitySprite.vframes = 1
			EntitySprite.hframes = 3
			set_collision_shape()
			set_entity_position()
		"craftable":
			return
			


func set_entity_position():
	var collisionshape_height = collisionShape2D.shape.extents.y * 2
	var collisionshape_floor_position = collisionShape2D.position + Vector2(0, collisionshape_height / 2)
	EntitySprite.position -= Vector2(0, collisionshape_floor_position.y)
	collisionShape2D.position -= Vector2(0, collisionshape_floor_position.y)

func set_collision_shape():
	var image_data: Image = EntitySprite.texture.get_data()
	var texture_size: Vector2 = EntitySprite.texture.get_size()
	var individual_frame_size: Vector2 = Vector2((texture_size.x / EntitySprite.hframes), (texture_size.y / EntitySprite.vframes))
	var current_sprite_frame: Image = get_sprite_frame(image_data, individual_frame_size)
	var shadow_length: int = get_shadow_length(current_sprite_frame)
	
	var converted_rect_dimensions: Vector2 = (get_usedrect_dimensions(current_sprite_frame) - Vector2(0, shadow_length)) / 2
	var converted_rect_position: Vector2 = get_usedrect_position(current_sprite_frame)
	
	collisionShape2D.shape.extents = converted_rect_dimensions
	collisionShape2D.position = (converted_rect_position + converted_rect_dimensions) + EntitySprite.position - (individual_frame_size / 2)


func get_sprite_frame(image_data, individual_frame_size) -> Image:
	var frame = Rect2(Vector2(0, individual_frame_size.y * facing), individual_frame_size)
	return image_data.get_rect(frame)

func get_usedrect_dimensions(image: Image) -> Vector2:
	var image_rect: Rect2 = image.get_used_rect()
	return image_rect.size

func get_usedrect_position(image: Image) -> Vector2:
	var image_rect: Rect2 = image.get_used_rect()
	return image_rect.position
	
func get_shadow_length(image):
	var sprite_image = image.get_rect(image.get_used_rect())
	var sprite_dimensions = get_usedrect_dimensions(sprite_image)
	var shadow_length = 0
	sprite_image.lock()
	for pixel in range(sprite_dimensions.y - 1, 0, -1):
		print("ALPHA", sprite_image.get_pixel(sprite_dimensions.x / 2, pixel).a)
		if sprite_image.get_pixel(sprite_dimensions.x / 2, pixel).a < 1:
			shadow_length += 1
		else:
			break
	return shadow_length
		
	

#func get_first_frame() -> Image:                   
#	var image_data: Image = EntitySprite.texture.get_data()
#	return image_data.get_rect(Rect2(Vector2(0, 0), Vector2(48, 64)))
#
#func get_last_frame() -> Image:
#	var image_data: Image = EntitySprite.texture.get_data()
#	return image_data.get_rect(Rect2(Vector2(0, 192), Vector2(48, 64)))
