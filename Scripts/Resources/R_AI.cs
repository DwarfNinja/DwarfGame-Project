using Godot;
using System;
using MonoCustomResourceRegistry;

[RegisteredType(nameof(R_AI))] 
public class R_AI : Resource {
    public enum Type {
        Villager
    }
    public enum Role {
        General,
        Kitchen,
        Livingroom
        
    }
    [Export]
    public Type AiName;
    
    [Export]
    public Role AiRole;
    
    [Export]
    public Texture AiSpriteSheet;
}