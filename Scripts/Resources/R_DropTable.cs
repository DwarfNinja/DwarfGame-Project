using Godot;
using System;
using Godot.Collections;
using Array = Godot.Collections.Array;
using MonoCustomResourceRegistry;

[RegisteredType(nameof(R_DropTable))] 
public class R_DropTable : Resource {
    [Export]
    public string DropTableName;
    
    [Export]
    public Array DropTable;
}
