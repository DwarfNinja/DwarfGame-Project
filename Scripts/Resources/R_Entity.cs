using Godot;
using System;

public class R_Entity : Node {
    private enum Theme {
        General,
        Kitchen,
        Livingroom
    }

    [Export]
    private Theme theme;
    
    [Export]
    private Vector2 tileFootprint;
    
    [Export]
    private Texture itemTexture;
    
    [Export]
    private Texture hudTexture;
}
