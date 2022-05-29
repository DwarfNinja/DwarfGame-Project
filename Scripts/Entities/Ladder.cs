using Godot;
using System;

public class Ladder : InteractableEntity {

    public override void Interact(Player interactingPlayer) {
        Events.EmitEvent(nameof(Events.ExitedCave));
    }
}
