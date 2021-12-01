using Godot;
using System;

public class R_Entity : R_Item {
    public enum Theme {
        General,
        Kitchen,
        Livingroom
    }

    [Export]
    public Theme EntityTheme;
    
    [Export]
    public Vector2 TileFootprint;
    
    [Export]
    public Vector2 CollisionFootprint;
    
    [Export]
    public Texture EntityTexture;
}
