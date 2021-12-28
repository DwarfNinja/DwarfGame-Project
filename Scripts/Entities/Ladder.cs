using Godot;
using System;

public class Ladder : InteractableEntity {

    public override void Interact(KinematicBody2D interactingKinematicBody) {
        Events.EmitEvent(nameof(Events.ExitedCave));
    }
}
