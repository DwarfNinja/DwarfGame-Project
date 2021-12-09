extends R_Item
class_name R_Entity

enum Themes {
	General,
	Kitchen,
	Livingroom
}

export(Themes) var EntityTheme;

export(Vector2) var TileFootprint;

export(Vector2) var CollisionFootprint;

export(Texture) var EntityTexture;
