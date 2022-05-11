using Godot;
using System;

public class Forge : InteractableEntity {

    private R_Item iron;
    
    private Texture iron1;
    private Texture iron2;
    
    private int forgeTime = 5;
    private int ironInForge;
    private int setIronAmount;
    
    private Timer forgeTimer;
    private Sprite ironSprite;

    public override void _Ready() {
        base._Ready();

        iron = (R_Item) GD.Load("res://Resources/Entities/Resources/Iron.tres");
        iron1 = (Texture) GD.Load("res://Sprites/Interactables/Craftables/Forge/Forge Iron1.png");
        iron2 = (Texture) GD.Load("res://Sprites/Interactables/Craftables/Forge/Forge Iron2.png");

        forgeTimer = (Timer) GetNode("ForgeTimer");
        ironSprite = (Sprite) GetNode("IronSprite");
        forgeTimer.Connect("timeout", this, nameof(OnForgeTimerTimeout));
    }

    public override void _Process(float delta) {
        if (canInteract) {
            if (forgeTimer.IsStopped() && ironInForge == 0) {
                ShowShader();
            }
            else if (ironInForge > 0) {
                HideShader();
                ShaderMaterial ironSpriteMaterial = (ShaderMaterial) ironSprite.Material;
                ironSpriteMaterial.SetShaderParam("outline_color", new Color(240,240,240,255));
            }
            else {
                HideShader();
                ShaderMaterial ironSpriteMaterial = (ShaderMaterial) ironSprite.Material;
                ironSpriteMaterial.SetShaderParam("outline_color", new Color(240,240,240,0));
            }
        }
        UpdateIronSprite();
    }

    public override void Interact(Player interactingPlayer) {
        if (ironInForge == 0) {
            Events.EmitEvent(nameof(Events.OpenForge), this, interactingPlayer);
        }
        else if (ironInForge > 0) {
            if (interactingPlayer.Inventory.PickUpItem(iron)) {
                ironInForge -= 1;
            }
        }
        else {
            GD.Print("Forge is still smelting!");
        }
    }

    private void UpdateIronSprite() {
        if (ironInForge > 0) {
            ironSprite.Texture = ironInForge <= 5 ? iron1 : iron2;
        }
        else {
            ironSprite.Texture = null;
        }
    }

    public void SetIronAmount(int ironAmount) {
        forgeTimer.WaitTime = forgeTime * ironAmount;
        forgeTimer.Start();
        setIronAmount = ironAmount;
    }

    private void OnForgeTimerTimeout() {
        if (ironInForge < 20) {
            ironInForge += 2 * setIronAmount;
        }
        UpdateIronSprite();
    }
}
