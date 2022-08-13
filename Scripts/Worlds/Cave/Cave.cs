using Godot;
using System;
using System.Linq;
using Godot.Collections;

public class Cave : Node2D {
    
    private PackedScene taxknightScene;
    private PackedScene playerScene;
    private PackedScene itemScene;
    
    private Vector2 tilepositionOffset = new Vector2(0,1);
    
    private Color dayColour = new Color("ffffff");
    private Color nightColor = new Color("2d2246");

    private TileMap floor;
    private YSort ySort;
    private Player player;
    private Position2D playerPosition2D;
    private Vector2 mapCoordOfPlayerPosition2D;
    private Sprite tileSelector;
    private CanvasModulate canvasModulate;

    private bool taxknightInstanced = false;
    private Array<Vector2> occupiedTiles = new Array<Vector2>();

    public override void _Ready() {
        taxknightScene = (PackedScene) GD.Load("res://Scenes/Interactables/TaxKnight.tscn");
        playerScene = (PackedScene) GD.Load("res://Scenes/KinematicBodies/Player.tscn");
        itemScene = (PackedScene) GD.Load("res://Scenes/Items/Item.tscn");

        floor = (TileMap) GetNode("Floor");
        ySort = (YSort) GetNode("YSort");
        player = (Player) GetNode("YSort/Player");
        playerPosition2D = (Position2D) GetNode("YSort/Player/InteractAreaAnchor/Position2D");
        mapCoordOfPlayerPosition2D = ((TileMap) GetNode("Floor")).WorldToMap(playerPosition2D.GlobalPosition);
        tileSelector = (Sprite) GetNode("YSort/TileSelector");
        canvasModulate = (CanvasModulate) GetNode("CanvasModulate");
        
        Events.ConnectEvent(nameof(Events.DayStarted), this, nameof(OnDayStarted));
        Events.ConnectEvent(nameof(Events.DayEnding), this, nameof(OnDayEnding));
        Events.ConnectEvent(nameof(Events.DayEnded), this, nameof(OnDayEnded));
        Events.ConnectEvent(nameof(Events.PlaceObject), this, nameof(OnPlaceObject));
        Events.ConnectEvent(nameof(Events.DropSelectedItem), this, nameof(OnDropSelectedItem));
        GameManager.ConnectEvent(nameof(GameManager.UpdatedGameTime), this, nameof(OnUpdatedGameTime));
    }

    public override void _Process(float delta) {
        if (player != null) {
            mapCoordOfPlayerPosition2D = ((TileMap) GetNode("Floor")).WorldToMap(playerPosition2D.GlobalPosition);
            UpdateTileSelector();
        }
    }

    private void UpdateTileSelector() {
        R_Item selectedItem = player.Inventory.SelectedItem;
        if (selectedItem != null) {
            tileSelector.Show();
            tileSelector.GlobalPosition = floor.MapToWorld(floor.WorldToMap(playerPosition2D.GlobalPosition)) + new Vector2(8, 8);
        }
        else {
            tileSelector.Hide();
        }
    }

    private bool IsTileEmpty(Vector2 tile) {
        return !occupiedTiles.Contains(tile);
    }

    private void OnDayStarted() {
        if (ySort.GetChildren().Contains(taxknightScene)) {
            GetNode("YSort/TaxKnight").QueueFree();
        }
    }

    private void OnDayEnding() {
        if (ySort.GetChildren().Contains(taxknightScene)) {
            KinematicBody2D taxknightInstance = (KinematicBody2D) taxknightScene.Instance();
            taxknightInstance.Position = ((Position2D) GetNode("TaxKnightPosition")).GlobalPosition;
            ySort.AddChild(taxknightInstance);
        }
    }

    private void OnDayEnded() {
        
    }

    private void OnPlaceObject(R_Craftable selectedItem) {
        if (IsTileEmpty(mapCoordOfPlayerPosition2D + tilepositionOffset)) {
            PackedScene selectedItemScene = (PackedScene) GD.Load(selectedItem.PackedsceneString);
            if (player.Inventory.RemoveItemFromInventory(selectedItem)) {
                Entity selectedItemInstance = (Entity) selectedItemScene.Instance();
                selectedItemInstance.GlobalPosition = floor.MapToWorld(mapCoordOfPlayerPosition2D + tilepositionOffset);
                ySort.AddChild(selectedItemInstance);
                foreach (int x in Enumerable.Range(0, (int) selectedItem.TileFootprint.x)) {
                    foreach (int y in Enumerable.Range(0, (int) selectedItem.TileFootprint.y)) {
                        occupiedTiles.Add(new Vector2(mapCoordOfPlayerPosition2D.x + x, mapCoordOfPlayerPosition2D.y + y) + tilepositionOffset);
                    }
                } 
            }
        }
        else {
            GD.Print("Can't place item here! " + selectedItem);
        }
    }

    private void OnDropSelectedItem(R_Item selectedItem) {
        PickableItem itemSceneInstance = (PickableItem) itemScene.Instance();
        itemSceneInstance.ItemDef = selectedItem;
        itemSceneInstance.GlobalPosition = player.GlobalPosition;
        ySort.AddChild(itemSceneInstance);
        player.Inventory.RemoveItemFromInventory(selectedItem);
    }

    public void OnUpdatedGameTime(float seconds, int dayStartTime) {
        canvasModulate.Color = dayColour.LinearInterpolate(nightColor, (float) (Math.Sin(seconds)+1) / 2);
    }
}
