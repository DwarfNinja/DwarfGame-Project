using Godot;
using System;
using Godot.Collections;
using MonoCustomResourceRegistry;

[RegisteredType(nameof(R_Craftable))] 
public class R_Craftable : R_Entity {
    [Export]
    public Dictionary<R_Item, int> RequiredItems;
    
    [Export]
    public Texture BlueprintIcon;
    
    [Export]
    public string PackedsceneString;
}