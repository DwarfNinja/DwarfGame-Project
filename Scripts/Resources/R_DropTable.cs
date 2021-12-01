using Godot;
using System;
using Godot.Collections;
using Array = Godot.Collections.Array;

public class R_DropTable : Resource {
    [Export]
    public string DroptableName;
    
    [Export]
    public Array Droptable;
}
