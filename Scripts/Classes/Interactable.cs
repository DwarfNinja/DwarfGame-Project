using Godot;
using System;

public interface Interactable {

    public CollisionShape2D CollisionShape2D {
        get;
        set;
    }
    
    
    public abstract void Interact(KinematicBody2D interactingKinematicBody);
    //Declared in the specific Interactable

    public abstract void InteractingBodyEntered();

    public abstract void InteractingBodyExited();
}
