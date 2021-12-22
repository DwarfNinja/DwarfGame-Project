using Godot;
using System;

public abstract class InteractableEntity : Entity, Interactable {

    private bool canInteract;
    private Area2D interactArea;
    private KinematicBody2D interactingBody;

    public override void _Ready() {
        base._Ready();
        interactArea = (Area2D) GetNode("InteractArea");
    }

    public CollisionShape2D CollisionShape2D { 
        get => collisionShape2D; 
        set => collisionShape2D = value; }

    public abstract void Interact(KinematicBody2D interactingKinematicBody);
    //Declared in the specific Craftable_Object

    public void InteractingBodyEntered() {
        ShaderMaterial entitySpriteMaterial = (ShaderMaterial) EntitySprite.Material;
        entitySpriteMaterial.SetShaderParam("outline_color", new Color(240,240,240,255));
    } 
    
    public void InteractingBodyExited() {
        ShaderMaterial entitySpriteMaterial = (ShaderMaterial) EntitySprite.Material;
        entitySpriteMaterial.SetShaderParam("outline_color", new Color(240,240,240,0));
    }
}
