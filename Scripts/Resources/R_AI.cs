using Godot;
using System;

public class R_AI : Resource {
    private enum Type {
        Villager,
    }
    [Export]
    private Type typeName;
    
    [Export]
    private string role;
    
    [Export]
    private Texture aiSpritesheet;
}
