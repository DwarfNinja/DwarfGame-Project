using Godot;
using System;

public class RW_DropTableEntry : Resource {
    private Resource R_DropTableEntry;

    public RW_DropTableEntry(Resource resource) {
        R_DropTableEntry = resource;
    }
    
    public static RW_Entity LoadResource(string filePath) {
        return new RW_Entity(ResourceLoader.Load<Resource>(filePath));
    }

    public RW_Item Item {
        get {
            Resource R_ItemResource = (Resource) R_DropTableEntry.Get("Item");
            RW_Item rwItem = new RW_Item(R_ItemResource);
            return rwItem;
        } 
        set => R_DropTableEntry.Set("Item", value);
    }

    public int DropRate {
        get => (int) R_DropTableEntry.Get("DropRate");
        set => R_DropTableEntry.Set("DropRate", value);
    }
}
