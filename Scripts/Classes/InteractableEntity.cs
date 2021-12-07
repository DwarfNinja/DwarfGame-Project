using Godot;
using System;

public abstract class InteractableEntity : Entity {

    private bool canInteract;
    private Area2D interactArea;
    
    public override void _Ready() {
        base._Ready();
        interactArea = (Area2D) GetNode("InteractArea");
        interactArea.Connect("area_entered", this, nameof(OnInteractAreaAreaEntered));
        interactArea.Connect("area_exited", this, nameof(OnInteractAreaAreaExited));
    }


    public override void _UnhandledInput(InputEvent @event) {
        if (canInteract) {
            if (@event.IsActionPressed("key_e")) {
                Interact();
            }
        }
    }

    private void OnInteractAreaAreaEntered(Node2D area) {
        canInteract = true;
        Console.WriteLine("NODENAME:" + nodename);
        ShaderMaterial entitySpriteMaterial = (ShaderMaterial) entitySprite.Material;
        entitySpriteMaterial.SetShaderParam("outline_color", new Color(240,240,240,255));
    } 
    
    private void OnInteractAreaAreaExited(Node2D area) {
        canInteract = false;
        ShaderMaterial entitySpriteMaterial = (ShaderMaterial) entitySprite.Material;
        entitySpriteMaterial.SetShaderParam("outline_color", new Color(240,240,240,0));
    }

    protected abstract void Interact();
    //Declared in the specific Craftable_Object
}
