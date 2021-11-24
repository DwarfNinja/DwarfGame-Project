using Godot;
using System;
using Godot.Collections;

public class R_Craftable : Resource {
    [Export]
    private Dictionary<R_Item, int> requiredItems;
    
    [Export]
    private Texture blueprintIcon;
    
    [Export]
    private string packedsceneString;
}
