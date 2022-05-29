using Godot;
using System;
using Godot.Collections;

public class Nav2D : Navigation2D {

    private Player player;
    private Node2D playerGhost;

    private Vector2 currentPlayerPosition;
    private Vector2 upToDateLastKnowPlayerPosition;
    
    public override void _Ready() {
        player = GetNode<Player>("Walls/Player");
        playerGhost = GetNode<Node2D>("Walls/PlayerGhost");
        
        Events.ConnectEvent(nameof(Events.RequestRoamCell), this, nameof(OnRequestRoamCell));
        Events.ConnectEvent(nameof(Events.RequestNavPath), this, nameof(OnRequestNavPath));
        Events.ConnectEvent(nameof(Events.UpdateLastKnownPlayerPosition), this, nameof(OnUpdateLastKnownPlayerPosition));
        playerGhost.GetNode<Area2D>("PlayerGhostArea").Connect("body_entered", this, nameof(OnPlayerGhostBodyEntered));
    }

    public override void _Process(float delta) {
        if (player != null) {
            currentPlayerPosition = player.GlobalPosition;
        }
    }

    private void OnRequestRoamCell(Villager villager) {
        Vector2 villagerSpawnPosition = GetNode<TileMap>("Areas").WorldToMap(villager.SpawnPosition);
        Array<Vector2> villagerRoamDesitinations = new Array<Vector2>();

        foreach (Vector2 cell in GetNode<TileMap>("Areas").GetUsedCells()) {
            if (cell.DistanceTo(villagerSpawnPosition)  > 10) {
                villagerRoamDesitinations.Add(GetNode<TileMap>("Areas").MapToWorld(cell) + new Vector2((float) 7.99, (float) 8.01)); // Bug in Nav2D where it rounds up ints?
            }
        }
        villagerRoamDesitinations.Shuffle();
        Vector2 firstRoamDestination = villagerRoamDesitinations[0];
        villagerRoamDesitinations.Remove(firstRoamDestination);
        Vector2 roamCell = firstRoamDestination;
        villager.randomRoamCell = roamCell;
    }

    private void OnRequestNavPath(Villager villager, Vector2 targetCell) {
        Array<Vector2> path = new Array<Vector2>(GetSimplePath(villager.GlobalPosition, targetCell, false));
        villager.path = path;
    }
    
    private void OnUpdateLastKnownPlayerPosition(Vector2 receivedPlayerPosition, Villager.States state) {
        if (receivedPlayerPosition.DistanceTo(currentPlayerPosition) <
            upToDateLastKnowPlayerPosition.DistanceTo(currentPlayerPosition)) {
            upToDateLastKnowPlayerPosition = receivedPlayerPosition;
        }

        if (state == Villager.States.Search) {
            playerGhost.GlobalPosition = upToDateLastKnowPlayerPosition;
            playerGhost.Visible = true;
        }
        else {
            playerGhost.Visible = false;
        }

        foreach (Villager villager in GetTree().GetNodesInGroup("Villager")) {
            villager.lastknownPlayerposition = upToDateLastKnowPlayerPosition;
        }
    }

    private void OnPlayerGhostBodyEntered(Node2D body) {
        playerGhost.Visible = false;
    }
}
