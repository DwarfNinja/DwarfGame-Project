extends R_Item
class_name R_Entity

enum THEME {GENERAL, KITCHEN, LIVINGROOM}

export (THEME) var theme
export (Vector2) var tile_footprint
export (Vector2) var collision_footprint
export (Texture) var entity_texture
