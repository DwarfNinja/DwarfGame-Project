using Godot;
using System;

public class R_Item : Resource {
    private enum Type {
        Resource,
        Lootable,
        Craftable,
        Prop
    }

    [Export]
    private Type entityType;
    
    [Export]
    private string entityName;
    
    [Export]
    private Texture itemTexture;
    
    [Export]
    private Texture hudTexture;
}
