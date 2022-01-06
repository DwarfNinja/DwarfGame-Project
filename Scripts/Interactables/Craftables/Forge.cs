using Godot;
using System;

public class Forge : InteractableEntity {

    private R_Item iron;
    
    private Texture iron1;
    private Texture iron2;
    
    private int forgeTime;
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
        Events.ConnectEvent(nameof(Events.IronAmountSet), this, nameof(OnIronAmountSet));
    }
    
    public override void _Process(float delta) {
    }

    public override void Interact(KinematicBody2D interactingKinematicBody) {
        Player player = (Player) interactingKinematicBody;
        if (ironInForge == 0) {
            Events.EmitEvent(nameof(Events.OpenForge), this);
        }
        else if (ironInForge > 0) {
            if (player.Inventory.PickUpItem(iron)) {
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

    private void OnIronAmountSet(Forge forge,int ironAmount) {
        if (Equals(forge)) {
            forgeTimer.WaitTime = forgeTime * ironAmount;
            forgeTimer.Start();
            setIronAmount = ironAmount;
        }
    }

    private void OnForgeTimerTimeout() {
        if (ironInForge < 20) {
            ironInForge += 2 * setIronAmount;
        }
        UpdateIronSprite();
    }
}
