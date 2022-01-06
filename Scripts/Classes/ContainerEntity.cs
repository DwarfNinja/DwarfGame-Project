using Godot;
using System;
using System.Collections;
using System.Linq;
using Godot.Collections;
using Array = Godot.Collections.Array;

public class ContainerEntity : InteractableEntity {

    [Export] 
    private R_DropTable dropTableDef;

    private PackedScene itemScene;
    private AnimationPlayer animationPlayer;
    private Position2D itemSpawnPosition;
    private bool containerOpened = false;
    private RandomNumberGenerator randomNumberGenerator = new RandomNumberGenerator();

    private Array<Vector2> directionList= new Array<Vector2>() {
        new Vector2(22,-20), new Vector2(0,-20), new Vector2(-22,-20),
        new Vector2(22,0), new Vector2(-22,0),
        new Vector2(-22,20), new Vector2(0,20), new Vector2(22,20),
    };
    
    public override void _Ready() {
        base._Ready();
        
        itemScene = (PackedScene) ResourceLoader.Load("res://Scenes/Items/Item.tscn");
        animationPlayer = (AnimationPlayer) GetNode("AnimationPlayer");
        itemSpawnPosition = (Position2D) GetNode("ItemSpawnPosition");
        
        randomNumberGenerator.Randomize();
    }

    public override void Interact(KinematicBody2D interactingKinematicBody) {
        switch (containerOpened) {
            case false:
                DropItems();
                animationPlayer.Play("Open");
                containerOpened = true;
                break;
            case true:
                animationPlayer.Play("Close");
                containerOpened = false;
                break;
        }
    }

    private void DropItems() {
        Array<Vector2> availableDirections = directionList.Duplicate();

        foreach (int item in Enumerable.Range(1, GetRandomItemAmount())) {
            R_Item randomItemResource = SelectItemFromDropTable();

            PickableItem randomItem = (PickableItem) itemScene.Instance();
            randomItem.ItemDef = randomItemResource;
            
            GetParent().AddChild(randomItem, true);
            randomItem.GlobalPosition = itemSpawnPosition.GlobalPosition;
            Vector2 randomDirection = GetRandomDropDirection(availableDirections);
            randomItem.PlayChestDropAnimation(randomDirection);
        }
    }

    private R_Item SelectItemFromDropTable() {
        Array<R_DropTableEntry> dropTable = dropTableDef.DropTable;
        int totalDropChance = 0;
        int cumulativeDropChance = 0;
        
        foreach (R_DropTableEntry dropTableEntry in dropTable) {
            totalDropChance += dropTableEntry.DropRate;
        }
        
        int rng = randomNumberGenerator.RandiRange(0, totalDropChance);
        foreach (R_DropTableEntry dropTableEntry in dropTable) {
            cumulativeDropChance += dropTableEntry.DropRate;
            //if the RNG is <= item cumulated total_drop_chance then drop that item
            if (rng <= cumulativeDropChance) {
                return dropTableEntry.Item;
            }
        }

        return null;
    }

    private Vector2 GetRandomDropDirection(Array<Vector2> availableDirectionList) {
        availableDirectionList.Shuffle();
        Vector2 randomDirection = availableDirectionList[0];
        availableDirectionList.RemoveAt(0);
        return randomDirection;
    }
    
    private int GetRandomItemAmount() {
        uint numberOfitems = randomNumberGenerator.Randi() % 3 + 2;
        return (int) numberOfitems;
    }
}
