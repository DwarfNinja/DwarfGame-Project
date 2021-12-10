using Godot;
using System;

public class RW_Item : ResourceWrapper {

    public enum Type {
        Item,
        Lootable,
        Craftable,
        Prop
    }

    public RW_Item(Resource resource) : base(resource) {
    }

    public static RW_Item LoadResource(string filePath) {
        return new RW_Item(ResourceLoader.Load<Resource>(filePath));
    }

    public Type EntityType {
        get => (Type) Resource.Get("EntityType");
        set => Resource.Set("EntityType", value);
    }
    
    public string EntityName {
        get => (string) Resource.Get("EntityName");
        set => Resource.Set("EntityName", value);
    }
    
    public Texture ItemTexture {
        get => (Texture) Resource.Get("ItemTexture");
        set => Resource.Set("ItemTexture", value);
    }
    
    public Texture HudTexture {
        get => (Texture) Resource.Get("HudTexture");
        set => Resource.Set("HudTexture", value);
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
        return Resource.GetHashCode();
    }
}
