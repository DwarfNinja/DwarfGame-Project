extends Resource
class_name R_Item

enum Type {
	Item,
	Lootable,
	Craftable,
	Prop
}

export(Type) var EntityType;

export(String) var EntityName;

export(Texture) var ItemTexture;

export(Texture) var HudTexture;
