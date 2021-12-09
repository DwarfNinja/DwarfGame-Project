extends Resource
class_name R_AI

enum Type {
	Villager
}

enum Role {
		General,
		Kitchen,
		Livingroom
}

export(Type) var AiName;

export(Role) var AiRole;

export(Texture) var AiSpriteSheet;
