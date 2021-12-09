using Godot;
using System;
using Godot.Collections;

public class RW_Craftable : RW_Entity {
    
    private Resource R_Craftable;
    
    public RW_Craftable(Resource resource) : base(resource) {
        R_Craftable = resource;
    }

    public static RW_Craftable LoadResource(string filePath) {
        return new RW_Craftable(ResourceLoader.Load<Resource>(filePath));
    }

    public Dictionary<RW_Item, int> RequiredItems {
        get => (Dictionary<RW_Item, int>) R_Craftable.Get("RequiredItems");
        set => R_Craftable.Set("RequiredItems", value);
    }
    
    public Texture BlueprintIcon {
        get => (Texture) R_Craftable.Get("BlueprintIcon");
        set => R_Craftable.Set("BlueprintIcon", value);
    }
    
    public string PackedsceneString {
        get => (string) R_Craftable.Get("PackedsceneString");
        set => R_Craftable.Set("PackedsceneString", value);
    }
}
