using Godot;
using System;
using MonoCustomResourceRegistry;

[RegisteredType(nameof(R_DropTableEntry))] 
public class R_DropTableEntry : Resource {
    [Export]
    public R_Item Item;
    
    [Export]
    public int DropRate;
}
