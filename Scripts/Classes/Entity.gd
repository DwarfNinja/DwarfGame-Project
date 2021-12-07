tool

extends StaticBody2D
class_name Entity

export (Resource) var entity_def setget set_entity_def

onready var node_name = get_name().lstrip("@").split("@", false, 1)[0].rstrip("0123456789")
onready var EntitySprite = get_node("EntitySprite")
onready var collisionShape2D = get_node("CollisionShape2D")

export var facing: int = 0

var sprite_data: Dictionary = {
	"converted_rect_dimensions": null,
	"absolute_sprite_position": null,
	"shadow_height": null
	}

enum {FRONT = 0, BACK = 1, LEFT = 2, RIGHT = 3}

func _ready() -> void:
	if not entity_def:
		if not Engine.editor_hint:
			EntitySprite.texture = null
			push_error("ERROR: No entity_def defined in entity " + str(self))
			get_tree().quit()
			return
		
	set_node_name()
	set_entity(entity_def)

func set_entity_def(_entity_def):
	entity_def = _entity_def
	
func _process(_delta: float) -> void:
	if Engine.editor_hint:
		if entity_def:
			$EntitySprite.texture = entity_def.EntityTexture
			
func set_node_name():
	var formatted_entity_name = entity_def.EntityName.capitalize().replace(" ", "")
	if get_name() != formatted_entity_name:
		set_name(formatted_entity_name)

func set_entity(_entity_def):
	entity_def = _entity_def
	EntitySprite.texture = entity_def.EntityTexture
	EntitySprite.frame_coords.y = facing
#	match entity_def.EntityType:
#		R_Item.TYPE.PROP:
#			EntitySprite.vframes = 4
#			EntitySprite.hframes = 1
#			set_collision_shape()
#			set_entity_position()
#		R_Item.TYPE.LOOTABLE:
#			EntitySprite.vframes = 1
#			EntitySprite.hframes = 3
#			set_collision_shape()
#			set_entity_position()
#		R_Item.TYPE.CRAFTABLE:
#			return


func set_entity_position():
	var collisionshape_height = collisionShape2D.shape.extents.y * 2
	var collisionshape_floor_position = collisionShape2D.position + Vector2(0, collisionshape_height / 2)
	collisionShape2D.position = Vector2(collisionShape2D.shape.extents.x, -collisionShape2D.shape.extents.y)
	EntitySprite.position = -sprite_data["absolute_sprite_position"] + Vector2(sprite_data["converted_rect_dimensions"].x, -sprite_data["converted_rect_dimensions"].y)

func set_collision_shape():
	var image_data: Image = EntitySprite.texture.get_data()
	var texture_size: Vector2 = EntitySprite.texture.get_size()
	var individual_frame_size: Vector2 = Vector2((texture_size.x / EntitySprite.hframes), (texture_size.y / EntitySprite.vframes))
	var current_sprite_frame: Image = get_sprite_frame(image_data, individual_frame_size)
	
	var shadow_height: int = get_shadow_height(current_sprite_frame)
	print(entity_def.EntityName, get_usedrect_dimensions(current_sprite_frame))
	sprite_data["converted_rect_dimensions"] = (get_usedrect_dimensions(current_sprite_frame) - Vector2(0, shadow_height)) / 2
	sprite_data["absolute_sprite_position"] = (get_usedrect_position(current_sprite_frame) - (individual_frame_size / 2)) + sprite_data["converted_rect_dimensions"]
	
	var rectShape = RectangleShape2D.new()
	match facing:
		LEFT,RIGHT:
			if sprite_data["converted_rect_dimensions"].x != sprite_data["converted_rect_dimensions"].y:
				rectShape.set_extents(Vector2(entity_def["collision_footprint"].y, entity_def["collision_footprint"].x) / 2)
			else:
				rectShape.set_extents(entity_def.CollisionFootprint / 2)
		FRONT, BACK:
			rectShape.set_extents(entity_def.CollisionFootprint / 2)
	collisionShape2D.set_shape(rectShape)

func get_sprite_frame(image_data, individual_frame_size) -> Image:
	var frame = Rect2(Vector2(0, individual_frame_size.y * facing), individual_frame_size)
	return image_data.get_rect(frame)

func get_usedrect_dimensions(image: Image) -> Vector2:
	var image_rect: Rect2 = image.get_used_rect()
	return image_rect.size

func get_usedrect_position(image: Image) -> Vector2:
	var image_rect: Rect2 = image.get_used_rect()
	return image_rect.position

func get_shadow_height(image):
	var sprite_image = image.get_rect(image.get_used_rect())
	var sprite_dimensions = get_usedrect_dimensions(sprite_image)
	print(sprite_dimensions)
	var shadow_height = 0
	sprite_image.lock()
	for pixely in range(sprite_dimensions.y - 1, 0, -1):
		for pixelx in range(0, sprite_dimensions.x):
			if sprite_image.get_pixel(pixelx, pixely).a >= 1:
				return shadow_height
		shadow_height += 1
	
