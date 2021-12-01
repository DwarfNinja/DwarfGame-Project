extends Resource
class_name R_Item

enum TYPE {RESOURCE, LOOTABLE, CRAFTABLE, PROP}
export (TYPE) var type
export (String) var entity_name
export (Texture) var item_texture
export (Texture) var hud_texture
