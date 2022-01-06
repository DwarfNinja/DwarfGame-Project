using Godot;
using System;
using MonoCustomResourceRegistry;

[RegisteredType(nameof(R_Item))] 
public class R_Item : Resource {
    public enum Type {
        Item,
        Interactable,
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

