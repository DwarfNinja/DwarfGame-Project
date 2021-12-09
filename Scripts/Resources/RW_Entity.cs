using Godot;
using System;

public class RW_Entity : RW_Item {
    
    private Resource R_Entity;
    
    public enum Theme {
        General,
        Kitchen,
        Livingroom
    }

    public RW_Entity(Resource resource) : base(resource) {
        R_Entity = resource;
    }

    public static RW_Entity LoadResource(string filePath) {
        return new RW_Entity(ResourceLoader.Load<Resource>(filePath));
    }

    public Theme EntityTheme {
        get => (Theme) R_Entity.Get("EntityTheme");
        set => R_Entity.Set("EntityTheme", value);
    }
    
    public Vector2 TileFootprint {
        get => (Vector2) R_Entity.Get("TileFootprint");
        set => R_Entity.Set("TileFootprint", value);
    }
    
    public Vector2 CollisionFootprint {
        get => (Vector2) R_Entity.Get("CollisionFootprint");
        set => R_Entity.Set("CollisionFootprint", value);
    }
    
    public Texture EntityTexture {
        get => (Texture) R_Entity.Get("EntityTexture");
        set => R_Entity.Set("EntityTexture", value);
    }
}
