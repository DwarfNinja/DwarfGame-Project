using Godot;
using System;

public class RW_AI : Resource {

    private Resource R_AI;

    public RW_AI() {
    }

    public RW_AI(Resource resource) {
        R_AI = resource;
    }
    
    public static RW_AI LoadResource(string filePath) {
        return new RW_AI(ResourceLoader.Load<Resource>(filePath));
    }
    
    public enum Type {
        Villager
    }
    public enum Role {
        General,
        Kitchen,
        Livingroom
    }

    public Type AiName {
        get => (Type) R_AI.Get("AiName");
        set => R_AI.Set("AiName", value);
    }

    public Role AiRole {
        get => (Role) R_AI.Get("AiRole");
        set => R_AI.Set("AiRole", value);
    }
    
    public Texture AiSpriteSheet {
        get => (Texture) R_AI.Get("AiSpriteSheet");
        set => R_AI.Set("AiSpriteSheet", value);
    }
    
}
