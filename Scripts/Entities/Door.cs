using Godot;
using System;

public class Door : InteractableEntity {
    
    public Position2D position2D;

    public override void _Ready() {
        base._Ready();
        position2D = GetNode<Position2D>("Position2D");
    }

    public override void Interact(Player interactingPlayer) {
        Events.EmitEvent(nameof(Events.EnteredCave));
    }
}

