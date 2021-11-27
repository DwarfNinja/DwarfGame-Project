using Godot;
using System;

public class R_Item : Resource {
    public enum Type {
        Resource,
        Lootable,
        Craftable,
        Prop
    }

    [Export]
    public Type EntityType;
    
    [Export]
    public string EntityName;
    
    [Export]
    public Texture ItemTexture;
    
    [Export]
    public Texture HudTexture;
}
