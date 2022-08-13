using Godot;
using System;

public abstract class InteractableEntity : Entity, Interactable {

    protected bool canInteract;
    private Player interactingPlayer;

    public CollisionShape2D CollisionShape2D { 
        get => collisionShape2D; 
        set => collisionShape2D = value; }

    public abstract void Interact(Player interactingPlayer);
    //Declared in the specific Craftable_Object

    public void InteractingBodyEntered() {
        canInteract = true;
        ShowShader();
    } 
    
    public void InteractingBodyExited() {
        canInteract = false;
        HideShader();
    }

    protected void ShowShader() {
        ShaderMaterial entitySpriteMaterial = (ShaderMaterial) EntitySprite.Material;
        entitySpriteMaterial.SetShaderParam("outline_color", new Color(240,240,240,255));
    }
    
    protected void HideShader() {
        ShaderMaterial entitySpriteMaterial = (ShaderMaterial) EntitySprite.Material;
        entitySpriteMaterial.SetShaderParam("outline_color", new Color(240,240,240,0));
    }
}
