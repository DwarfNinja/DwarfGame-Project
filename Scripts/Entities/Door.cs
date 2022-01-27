using Godot;
using System;

public class Door : InteractableEntity {

    public override void Interact(KinematicBody2D interactingKinematicBody) {
        Events.EmitEvent(nameof(Events.EnteredCave));
    }
}

