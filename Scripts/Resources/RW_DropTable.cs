using Godot;
using System;
using System.Linq;
using Godot.Collections;
using Array = Godot.Collections.Array;

public class RW_DropTable : Resource {

    private Resource R_DropTable;
    
    public RW_DropTable(Resource resource) {
        R_DropTable = resource;
    }
    
    public static RW_DropTable LoadResource(string filePath) {
        return new RW_DropTable(ResourceLoader.Load<Resource>(filePath));
    }

    public string DropTableName {
        get => (string) R_DropTable.Get("DropTableName");
        set => R_DropTable.Set("DropTableName", value);
    }

    public  Array<RW_DropTableEntry>DropTable {
        get {
            Array DropTableResourceArray = (Array) R_DropTable.Get("DropTable");
            
            Array<RW_DropTableEntry> DropTableEntryArray = new Array<RW_DropTableEntry>();
            
            foreach (Resource dropTableEntryResource in DropTableResourceArray) {
                RW_DropTableEntry dropTableEntry = new RW_DropTableEntry(dropTableEntryResource);
                DropTableEntryArray.Add(dropTableEntry);
            }
            return DropTableEntryArray;
        } 
        set => R_DropTable.Set("DropTable", value);
    }
}
