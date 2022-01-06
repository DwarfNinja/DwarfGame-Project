using Godot;
using System;

public class MiningRig : InteractableEntity {
    
    private R_Item goldCoins;

    private Texture goldCoins1;
    private Texture goldCoins2;
    
    private Timer miningRigTimer;
    private Sprite goldCoinsSprite;

    private bool miningTimerTimedOut = false;
    private int goldCoinsInMine = 0;
    
    public override void _Ready() {
        base._Ready();
        goldCoins = (R_Item) GD.Load("res://Resources/Entities/Resources/GoldCoins.tres");
        
        goldCoins1 = (Texture) GD.Load("res://Sprites/Interactables/Craftables/MiningRig/CoinsOne.png");
        goldCoins2 = (Texture) GD.Load("res://Sprites/Interactables/Craftables/MiningRig/CoinsTwo.png");
        
        miningRigTimer = (Timer) GetNode("MiningTimer");
        goldCoinsSprite = (Sprite) GetNode("GoldCoins");

        miningRigTimer.Connect("timeout", this, nameof(OnMiningTimerTimeout));
    }
    
    public override void _Process(float delta) {
        UpdateGoldCoinSprite();
    }

    public override void Interact(KinematicBody2D interactingKinematicBody) {
        Player player = (Player) interactingKinematicBody;
        if (goldCoinsInMine > 0) {
            if (player.Inventory.PickUpItem(goldCoins)) {
                goldCoinsInMine -= 1; 
            }
        }
        else {
            GD.Print("MiningRig is empty!");
        }
    }

    private void UpdateGoldCoinSprite() {
        Texture dynamicGoldCoins = (Texture) Get("goldCoins" + goldCoinsInMine);
        goldCoinsSprite.Texture = goldCoinsInMine > 0 ? goldCoinsSprite.Texture = dynamicGoldCoins : null;
    }
    
    private void OnMiningTimerTimeout() {
        if (goldCoinsInMine < 2) {
            goldCoinsInMine += 1;
        }
    }
}
