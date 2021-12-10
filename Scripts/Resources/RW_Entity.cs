using Godot;
using System;

public class RW_Entity : RW_Item {

    public enum Theme {
        General,
        Kitchen,
        Livingroom
    }

    public RW_Entity(Resource resource) : base(resource) {
    }

    public static RW_Entity LoadResource(string filePath) {
        return new RW_Entity(ResourceLoader.Load<Resource>(filePath));
    }

    public Theme EntityTheme {
        get => (Theme) Resource.Get("EntityTheme");
        set => Resource.Set("EntityTheme", value);
    }
    
    public Vector2 TileFootprint {
        get => (Vector2) Resource.Get("TileFootprint");
        set => Resource.Set("TileFootprint", value);
    }
    
    public Vector2 CollisionFootprint {
        get => (Vector2) Resource.Get("CollisionFootprint");
        set => Resource.Set("CollisionFootprint", value);
    }
    
    public Texture EntityTexture {
        get => (Texture) Resource.Get("EntityTexture");
        set => Resource.Set("EntityTexture", value);
    }
}
