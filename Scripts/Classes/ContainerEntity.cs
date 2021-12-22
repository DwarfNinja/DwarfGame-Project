using Godot;
using System;
using System.Collections;
using System.Linq;
using Godot.Collections;

public class ContainerEntity : InteractableEntity {

    [Export] 
    private Resource dropTableDefResource;
    
    private RW_DropTable dropTableDef;

    private PackedScene itemScene;
    private AnimationPlayer animationPlayer;
    private Position2D itemSpawnPosition;
    private RandomNumberGenerator randomNumberGenerator = new RandomNumberGenerator();

    private Array<Vector2> directionList= new Array<Vector2>() {
        new Vector2(22,-20), new Vector2(0,-20), new Vector2(-22,-20),
        new Vector2(22,0), new Vector2(-22,0),
        new Vector2(-22,20), new Vector2(0,20), new Vector2(22,20),
    };
    
    public override void _Ready() {
        base._Ready();

        dropTableDef = new RW_DropTable(dropTableDefResource);
        itemScene = (PackedScene) ResourceLoader.Load("res://Scenes/Items/Item.tscn");
        animationPlayer = (AnimationPlayer) GetNode("AnimationPlayer");
        itemSpawnPosition = (Position2D) GetNode("ItemSpawnPosition");
        
        randomNumberGenerator.Randomize();
    }

    public override void Interact(KinematicBody2D interactingKinematicBody) {
        switch (animationPlayer.AssignedAnimation) {
            case "Close":
                DropItems();
                animationPlayer.Play("Open");
                break;
            case "Open":
                DropItems();
                animationPlayer.Play("Close");
                break;
            default:
                DropItems();
                animationPlayer.Play("Open");
                break;
        }
    }

    private void DropItems() {
        Array<Vector2> availableDirections = directionList.Duplicate();

        foreach (int item in Enumerable.Range(1, GetRandomItemAmount())) {
            RW_Item randomItemResource = SelectItemFromDropTable();

            PickableItem randomItem = (PickableItem) itemScene.Instance();
            randomItem.ItemDef = randomItemResource;
            
            AddChild(randomItem, true);
            randomItem.GlobalPosition = itemSpawnPosition.GlobalPosition;
            Vector2 randomDirection = GetRandomDropDirection(availableDirections);
            randomItem.PlayChestDropAnimation(randomDirection);
        }
    }

    private RW_Item SelectItemFromDropTable() {
        Array<RW_DropTableEntry> dropTable = dropTableDef.DropTable;
        int totalDropChance = 0;
        int cumulativeDropChance = 0;
        
        foreach (RW_DropTableEntry dropTableEntry in dropTable) {
            totalDropChance += dropTableEntry.DropRate;
        }
        
        int rng = (int) randomNumberGenerator.Randi() % totalDropChance;
        foreach (RW_DropTableEntry dropTableEntry in dropTable) {
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
