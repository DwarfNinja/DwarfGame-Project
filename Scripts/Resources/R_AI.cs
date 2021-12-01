using Godot;
using System;

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
