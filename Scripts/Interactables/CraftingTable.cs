using Godot;
using System;

public class CraftingTable : InteractableEntity {
    
    public override void Interact(Player interactingPlayer) {
        Events.EmitEvent(nameof(Events.OpenCraftingTable)); 
    }
}
