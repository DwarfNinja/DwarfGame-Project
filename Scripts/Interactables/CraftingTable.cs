using Godot;
using System;

public class CraftingTable : InteractableEntity {
    
    public override void Interact(KinematicBody2D interactingKinematicBody) {
        Events.EmitEvent(nameof(Events.OpenCraftingTable)); 
    }
}
