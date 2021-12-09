using Godot;
using System;

public class RW_Item : Resource {

    public Resource R_Item;
    
    public enum Type {
        Item,
        Lootable,
        Craftable,
        Prop
    }

    public RW_Item(Resource resource) {
        R_Item = resource;
    }

    public static RW_Item LoadResource(string filePath) {
        return new RW_Item(ResourceLoader.Load<Resource>(filePath));
    }

    public Type EntityType {
        get => (Type) R_Item.Get("EntityType");
        set => R_Item.Set("EntityType", value);
    }
    
    public string EntityName {
        get => (string) R_Item.Get("EntityName");
        set => R_Item.Set("EntityName", value);
    }
    
    public Texture ItemTexture {
        get => (Texture) R_Item.Get("ItemTexture");
        set => R_Item.Set("ItemTexture", value);
    }
    
    public Texture HudTexture {
        get => (Texture) R_Item.Get("HudTexture");
        set => R_Item.Set("HudTexture", value);
    }

    public override bool Equals(object obj) {
        if (obj == null) {
            return false;
        }
        if (obj.GetType() == GetType()) {
            return ((RW_Item) obj).EntityName == EntityName;
        }
        return false;
    }

    public override int GetHashCode() {
        return R_Item.GetHashCode();
    }
}
