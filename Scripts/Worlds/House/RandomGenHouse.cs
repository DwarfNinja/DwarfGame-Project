using System;
using System.Linq;
using Godot;
using Godot.Collections;

public class RandomGenHouse : Node2D {
    
    //TileSets
    private TileSet houseTileSet = GD.Load<TileSet>("res://Tilesets/HouseTileset.tres");
    
    //Node references
    private Node2D houseRooms;
    private Node2D houseShapes;
    private TileMap topConnectionEnd;
    private TileMap L_SideConnectionEnd;
    private TileMap R_SideConnectionEnd;
    
    //TileMap references
    private TileMap walls;
    private TileMap floor;
    private TileMap areas;
    private TileMap indexes;
    private TileMap props;
    
    //Containers
    private PackedScene chestScene = GD.Load<PackedScene>("res://Scenes/Interactables/Chest.tscn");
    
    //KinematicBodies
    private PackedScene villagerScene = GD.Load<PackedScene>("res://Scenes/KinematicBodies/Villager.tscn");
    private Player player;
    
    //Objects
    private PackedScene doorScene = GD.Load<PackedScene>("res://Scenes/Entities/Door.tscn");
    private Node2D playerGhost;
    
    //TileID's Tiles
    private int floorTileID;
    private int wallsTileID;
    private int frontWallsTileID;
    private int wallShadowTileID;
    
    //TileIDs Indexes
    private int areaTileID;
    private int lootIndexTileID;
    private int enemyIndexTileID;
    private int spawnIndexTileID;
    
    //DropTables
    private R_DropTable containerDropTable = GD.Load<R_DropTable>("res://Resources/Drop_Tables/ContainerDropTable.tres");
    private R_DropTable enemiesDropTable = GD.Load<R_DropTable>("res://Resources/Drop_Tables/EnemiesDropTable.tres");

    
    private Array<Vector2> occupiedRoomLocations = new Array<Vector2>();
    private int rooms;
    private int maxRooms = 2;

    private Room lastRoom;
    private Vector2 lastRoomLocation;

    private int shapes;
    private int maxShapes;

    private Array<Vector2> spawnZone = new Array<Vector2>();

    private int maxContainers;
    private int maxEnemies;

    private Rect2 tileMapRect;
    
    //Map offset coordinations for placement of rooms
    private Vector2 roomPosStart;
    private Vector2 roomPosNorth;
    private Vector2 roomPosEast;
    private Vector2 roomPosSouth;
    private Vector2 roomPosWest;

    public override void _Ready() {
        houseRooms = GetNode<Node2D>("HouseRooms");
        houseShapes = GetNode<Node2D>("HouseShapes");
        topConnectionEnd = GetNode<TileMap>("ConnectionEnds/TopConnectionEnd");
        L_SideConnectionEnd = GetNode<TileMap>("ConnectionEnds/L_SideConnectionEnd");
        R_SideConnectionEnd = GetNode<TileMap>("ConnectionEnds/R_SideConnectionEnd");

        walls = GetNode<TileMap>("Nav2D/Walls");
        floor = GetNode<TileMap>("Nav2D/Floor");
        areas = GetNode<TileMap>("Nav2D/Areas");
        indexes = GetNode<TileMap>("Nav2D/Indexes");
        props = GetNode<TileMap>("Nav2D/Props");

        player = GetNode<Player>("Nav2D/Walls/Player");

        playerGhost = GetNode<Node2D>("Nav2D/Walls/PlayerGhost");
        
        floorTileID = houseTileSet.FindTileByName("Floor");
        wallsTileID = houseTileSet.FindTileByName("Walls");
        frontWallsTileID = houseTileSet.FindTileByName("Front_Walls");
        wallShadowTileID = houseTileSet.FindTileByName("WallShadow");
        
        areaTileID = houseTileSet.FindTileByName("AreaIndex");
        lootIndexTileID = houseTileSet.FindTileByName("ContainerIndex");
        enemyIndexTileID = houseTileSet.FindTileByName("EnemyIndex");
        spawnIndexTileID = houseTileSet.FindTileByName("SpawnIndex");

        switch (maxRooms) {
            case 2:
                maxShapes = 3;
                maxContainers = 3;
                maxEnemies = 3;
                break;
            case 3:
                maxShapes = 5;
                maxContainers = 4;
                maxEnemies = 4;
                break;
            default:
                throw new NotImplementedException();
        }
        
        Setup();
        RandomGeneration();
    }

    public override void _Process(float delta) {
        if (Input.IsActionJustPressed("key_r")) {
            GetTree().ReloadCurrentScene();
            GD.Print("___________________________________");
        }

        if (Input.IsActionJustPressed("ui_accept")) {
        }

        Vector2 mousePos = GetGlobalMousePosition();
        Vector2 cell = walls.WorldToMap(mousePos);

        // if (Input.IsActionJustPressed("f")) {
        //     GD.Print(cell);
        // }
    }

    private void Setup() {
        tileMapRect = floor.GetUsedRect();
        float tileMapRectSizeX = tileMapRect.Size.x;
        float tileMapRectSizeY = tileMapRect.Size.y;

        roomPosStart = new Vector2(0, 0);
        roomPosNorth = new Vector2(0, -tileMapRectSizeY);
        roomPosEast = new Vector2(tileMapRectSizeX, 0);
        roomPosSouth = new Vector2(0, tileMapRectSizeY);
        roomPosWest = new Vector2(-tileMapRectSizeX, 0);
    }

    private void RandomGeneration() {
        CheckRandomRoomViability();
        CheckExtentOfShape();
        CleanupRandomGen();
        PlacePlayerSpawn();
        PlaceEnemies();
        PlaceLoot();
        Events.EmitEvent(nameof(Events.RandomGenHouseLoaded));
    }

    private void CleanupRandomGen() {
        FillOuterWalls();
        CheckUnusedOpenings(occupiedRoomLocations);
        ClearTileConflict();
        // AddAreasToTopOfWall();
        UpdateAllCellBitmasks();
    }

    private void CheckRandomRoomViability() {
        string randomRoomDirection = null;

        while (rooms < maxRooms) {
            Array<Room> rooms = new Array<Room>(houseRooms.GetChildren());
            Room newRoom = SelectRandomFromArray(rooms);
            Array<string> possibleNewRoomDirections = new Array<string>();

            if (lastRoom == null) {
                //Place first room on (0,0)
                lastRoomLocation = roomPosStart;
                SetRandomRoom(newRoom, roomPosStart, lastRoomLocation);
                lastRoom = (Room) newRoom.Duplicate();
                occupiedRoomLocations.Add(lastRoomLocation);
                continue;
            }

            foreach (string direction in lastRoom.Openings.Keys) {
                if (lastRoom.Openings[direction] && newRoom.GetConnection(direction)) {
                    possibleNewRoomDirections.Add(direction);
                }
            }

            if (randomRoomDirection != null) {
                possibleNewRoomDirections.Remove(lastRoom.Mapping[randomRoomDirection]);
            }

            if (possibleNewRoomDirections.Count > 0) {
                randomRoomDirection = SelectRandomFromArray(possibleNewRoomDirections);
                Vector2 convertedRandomroomPosition = LocationOfValue(randomRoomDirection);
                if (occupiedRoomLocations.Contains(lastRoomLocation + convertedRandomroomPosition)) {
                    CheckRandomRoomViability();
                }
                SetRandomRoom(newRoom, convertedRandomroomPosition, lastRoomLocation);
                GD.Print("OCCUPIED ROOMS = " + occupiedRoomLocations);
                lastRoom = (Room) newRoom.Duplicate();
                lastRoomLocation = convertedRandomroomPosition + lastRoomLocation;
                occupiedRoomLocations.Add(lastRoomLocation);
            }
        }
    }

    private void SetRandomRoom(Node2D randomRoom, Vector2 randomRoomLocation, Vector2 lastRoomLocation) {
        Array<Node2D> templates = new Array<Node2D>(randomRoom.GetNode<Node2D>("Templates").GetChildren());
        Node2D randomRoomTemplate = SelectRandomFromArray(templates);
        TileMap randomRoomFloor = randomRoom.GetNode<TileMap>("Floor");
        TileMap randomRoomWalls = randomRoomTemplate.GetNode<TileMap>("Walls");
        TileMap randomRoomAreas = randomRoomTemplate.GetNode<TileMap>("Areas");
        TileMap randomRoomIndexes = randomRoomTemplate.GetNode<TileMap>("Indexes");
        
        GD.Print("ROOM = " + randomRoom.Name);
        GD.Print("ROOM POSITION CALCULATION = " + lastRoomLocation + " + " + randomRoomLocation 
                 + " = " + lastRoomLocation + randomRoomLocation);

        CopyTileMap(randomRoomFloor, floor, (randomRoomLocation + lastRoomLocation));
        CopyTileMap(randomRoomWalls, walls, (randomRoomLocation + lastRoomLocation));
        CopyTileMap(randomRoomAreas, areas, (randomRoomLocation + lastRoomLocation));
        CopyTileMap(randomRoomIndexes, indexes, (randomRoomLocation + lastRoomLocation));

        CopyNodes(randomRoomTemplate.GetNode<Node2D>("Props"), walls, walls.MapToWorld(randomRoomLocation) + lastRoomLocation);
        
        rooms += 1;
    }

    private void CheckExtentOfShape() {
        while (shapes < maxShapes) {
            Shape randomShape = SelectRandomFromArray(new Array<Shape>(houseShapes.GetChildren()));
            int randomShapeWidth = randomShape.ShapeWidth;
            int randomShapeHeight = randomShape.ShapeHeight;
            Array<Vector2> possibleShapeLocations = new Array<Vector2>();

            foreach (Vector2 cell in areas.GetUsedCells()) {
                Array<Vector2> shapeFootprint = GetTilesInRectangle(cell, randomShapeWidth, randomShapeHeight);
                if (ShapeFootprintIsEmpty(shapeFootprint)) {
                    possibleShapeLocations.Add(cell);
                }
            }
            // Selects a random shape location if there is at least 1 viable location
            if (possibleShapeLocations.Count > 0) {
                Vector2 selectedShapeLocation = SelectRandomFromArray(possibleShapeLocations);
                SetShape(randomShape, selectedShapeLocation);
            }
        }
    }

    private bool ShapeFootprintIsEmpty(Array<Vector2> shapeFootprint) {
        foreach (Vector2 cell in shapeFootprint) {
            if (areas.GetCellv(cell) == -1 || walls.GetCellv(cell) != -1) {
                return false;
            }
        }
        
        return true;
    }

    private void SetShape(Shape randomShape, Vector2 selectedShapeLocation) {
        TileMap randomShapeWalls = randomShape.GetNode<TileMap>("Walls");
        //Sets the shape in Walls
        CopyTileMap(randomShapeWalls, walls, selectedShapeLocation);
        shapes += 1;
    }

    private void FillOuterWalls() {
        Array<Vector2> perimiterCells = new Array<Vector2>();
        foreach (int cycle in GD.Range(0, 2)) {
            foreach (Vector2 cell in floor.GetUsedCells()) {
                if (floor.GetCell((int) (cell.x - 1),(int)  cell.y) == -1) {
                    foreach (int index in GD.Range(1, (int) tileMapRect.Size.x)) {
                        perimiterCells.Add(new Vector2(cell.x - 1 * index, cell.y));
                    }
                }
                if (floor.GetCell((int) (cell.x + 1), (int) cell.y) == -1) {
                    foreach (int index in GD.Range(1, (int) tileMapRect.Size.x)) {
                        perimiterCells.Add(new Vector2(cell.x + 1 * index, cell.y));
                    }
                }
                if (floor.GetCell((int) cell.x,(int)  cell.y - 1) == -1) {
                    foreach (int index in GD.Range(1, (int) tileMapRect.Size.y)) {
                        perimiterCells.Add(new Vector2(cell.x, cell.y - 1 * index));
                    }
                }
                if (floor.GetCell((int) cell.x,(int)  cell.y + 1) == -1) {
                    foreach (int index in GD.Range(1, (int) tileMapRect.Size.y)) {
                        perimiterCells.Add(new Vector2(cell.x, cell.y + 1 * index));
                    }
                }
            }

            foreach (Vector2 cell in perimiterCells) {
                floor.SetCell((int) cell.x, (int) cell.y, floorTileID, false, false, false, walls.GetCellAutotileCoord((int) cell.x, (int) cell.y));
                walls.SetCell((int) cell.x, (int) cell.y, wallsTileID, false, false, false, walls.GetCellAutotileCoord((int) cell.x, (int) cell.y));
            }
        }
    }

    private void CheckUnusedOpenings(Array<Vector2> occupiedRoomLocations) {
        Array<Vector2> topConnections = new Array<Vector2>{ new Vector2(2,0), new Vector2(11, 0) };
        Array<Vector2> sideConnections = new Array<Vector2>{ new Vector2(0,11), new Vector2(22, 11) };
        
        foreach (Vector2 cell in occupiedRoomLocations) {
            foreach (Vector2 _cell in topConnections) {
                if (walls.GetCellv(cell + _cell + Vector2.Up) != -1 && walls.GetCellv(cell + _cell) == -1) {
                    SetConnectionEnd(cell + _cell + Vector2.Left, topConnectionEnd);
                }

                if (walls.GetCellv(cell + _cell + new Vector2(-2, 3)) == wallShadowTileID) {
                    walls.SetCell((int) cell.x + (int)  _cell.x - 2, (int) cell.y + (int) _cell.y + 3, wallShadowTileID,
                        false, false, false, new Vector2(2, 0));
                }
                
                if (walls.GetCellv(cell + _cell + new Vector2(2, 3)) == wallShadowTileID) {
                    walls.SetCell((int) cell.x + (int) _cell.x + 2,(int) cell.y + (int) _cell.y + 3, wallShadowTileID,
                        false, false, false, new Vector2(2, 0));
                }
                
                // Set Areas based on touching Area
                areas.SetCellv(cell + _cell + new Vector2(-1,3), areas.GetCellv(cell + _cell + new Vector2(0, 4)));
                areas.SetCellv(cell + _cell + new Vector2(0,3), areas.GetCellv(cell + _cell + new Vector2(0, 4)));
                areas.SetCellv(cell + _cell + new Vector2(1,3), areas.GetCellv(cell + _cell + new Vector2(0, 4)));
            }
        }

        foreach (Vector2 cell in occupiedRoomLocations) {
            foreach (Vector2 _cell in sideConnections) {
                if (walls.GetCellv(cell + _cell + Vector2.Left) != -1 && walls.GetCellv(cell + _cell) == -1) {
                    SetConnectionEnd(cell + _cell + new Vector2(0, -4), L_SideConnectionEnd);
                    // Set Areas based on touching Area
                    areas.SetCellv(cell + _cell + Vector2.Up, areas.GetCellv(cell + _cell));
                }
                
                
                if (walls.GetCellv(cell + _cell + Vector2.Right) != -1 && walls.GetCellv(cell + _cell) == -1) {
                    SetConnectionEnd(cell + _cell + new Vector2(0, -4), R_SideConnectionEnd);
                    
                    // Set Areas based on touching Area
                    areas.SetCellv(cell + _cell + Vector2.Up, areas.GetCellv(cell + _cell));
                }
            }
        }
    }

    private void SetConnectionEnd(Vector2 unusedOpeningLocation, TileMap connectionEnd) {
        CopyTileMap(connectionEnd, walls, unusedOpeningLocation);
        foreach (Vector2 cell in  connectionEnd.GetUsedCells()) {
            //Clear Area cells in placed connection end
            areas.SetCellv(new Vector2(unusedOpeningLocation.x + cell.x, unusedOpeningLocation.y + cell.y), -1);
        }
    }

    private void ClearTileConflict() {
        foreach (Vector2 cell in walls.GetUsedCells()) {
            if (walls.GetCellv(cell) == frontWallsTileID || walls.GetCellv(cell) == wallsTileID) {
                // Clear cells in Area used in Walls
                areas.SetCellv(cell, -1);
                // Clear cells in Indexes used in Walls
                if (indexes.GetCellv(cell) != spawnIndexTileID) {
                    indexes.SetCellv(cell, -1);
                }
            }
        }
    }

    private void AddAreasToTopOfWall() {
        foreach (Vector2 cell in walls.GetUsedCellsById(wallsTileID)) {
            if (walls.GetCellv(cell + Vector2.Up) == -1 || walls.GetCellv(cell + Vector2.Up) == wallShadowTileID) {
                areas.SetCellv(cell, areas.GetCellv(cell + Vector2.Up));
            }
        }
    }

    private void UpdateAllCellBitmasks() {
        foreach (Vector2 cell in walls.GetUsedCells()) {
            walls.UpdateBitmaskArea(cell);
        }
    }
    
    private void PlacePlayerSpawn() {
        Array<Vector2> spawnTileArray = new Array<Vector2>(indexes.GetUsedCellsById(spawnIndexTileID));
        Vector2 randomSpawnPosition = SelectRandomSpawnPosition(spawnTileArray);
        Vector2 tilePos = walls.MapToWorld(randomSpawnPosition);
        Door door = PlaceDoor(randomSpawnPosition, tilePos);
        PlacePlayer(door);
        PlaceSpawnZone(door);
        // Remove index tiles in spawn zone
        foreach (Vector2 cell in spawnTileArray) {
            indexes.SetCellv(cell, -1);
        }
    }
    
    private Door PlaceDoor(Vector2 randomSpawnPosition, Vector2 tilepos) {
        Door doorInstance = doorScene.Instance<Door>();
        walls.SetCellv(randomSpawnPosition, -1);
        walls.SetCellv(new Vector2(randomSpawnPosition.x + 1, randomSpawnPosition.y), -1);
        walls.SetCellv(new Vector2(randomSpawnPosition.x + 2, randomSpawnPosition.y), -1);
        walls.AddChild(doorInstance);
        doorInstance.Position = tilepos;
        return doorInstance;
    }

    private void PlacePlayer(Door doorInstance) {
        player.Position = doorInstance.position2D.GlobalPosition;
        player.SetBlendPosition("Idle", new Vector2(0, (float) -0.1) );
    }

    private void PlaceSpawnZone(Node2D doorInstance) {
        // Position offset to compensate so the zone isn't in the wall
        int spawnZoneWidth = 15;
        int spawnZoneHeight = 8;
        spawnZone = GetTilesInRectCentre(
            walls.WorldToMap(doorInstance.Position) -
            new Vector2(-1, (float) (Math.Ceiling((double) (spawnZoneHeight / 2)) + 1)), spawnZoneWidth, spawnZoneHeight);

        foreach (Vector2 cell in spawnZone) {
            if (indexes.GetCellv(cell) != -1) {
                indexes.SetCellv(cell, -1);
            }
        }
    }

    private void PlaceEnemies() {
        // Array<Vector2> enemyTileArray = new Array<Vector2>(indexes.GetUsedCellsById(enemyIndexTileID));
        Array<Vector2> enemyTileArray = new Array<Vector2>(areas.GetUsedCellsById(areaTileID).Duplicate());
        foreach (Vector2 cell in spawnZone) {
            if (enemyTileArray.Contains(cell)) {
                enemyTileArray.Remove(cell);
            }
        }

        Array<Vector2> randomEnemyPositions = SelectRandomNodePositions(enemyTileArray, maxEnemies);
        PlaceNodesInTileMap(enemiesDropTable, randomEnemyPositions, new Vector2((float) 7.99, (float) 9.01));
    }

    private void PlaceLoot() {
        Array<Vector2> lootTileArray = new Array<Vector2>(indexes.GetUsedCellsById(lootIndexTileID));
        Array<Vector2> randomLootPositions = SelectRandomNodePositions(lootTileArray, maxContainers);
        PlaceNodesInTileMap(containerDropTable, randomLootPositions, Vector2.Zero);
    }

    private void CopyTileMap(TileMap donorMap, TileMap recipientMap, Vector2 placementPosition) {
        foreach (Vector2 cell in donorMap.GetUsedCells()) {
            recipientMap.SetCell((int) cell.x + (int) placementPosition.x, (int) cell.y + (int) placementPosition.y, 
                donorMap.GetCellv(cell), false, false, false, 
                donorMap.GetCellAutotileCoord((int) cell.x, (int) cell.y));
        }
    }

    private void CopyNodes(Node2D donorNode, Node2D recipientNode, Vector2 nodeOffset) {
        foreach (Node2D node in donorNode.GetChildren()) {
            Node2D nodeDuplicate = (Node2D) node.Duplicate();
            recipientNode.AddChild(nodeDuplicate);
            nodeDuplicate.GlobalPosition += nodeOffset;
        }
    }

    private void PlaceNodesInTileMap(R_DropTable dropTable, Array<Vector2> nodePositions, Vector2 positionOffset) {
        foreach (int i in Enumerable.Range(0, nodePositions.Count)) {
            PackedScene nodePackedScene = (PackedScene) SelectItemFromDropTable(dropTable);
            Node2D nodeInstance = nodePackedScene.Instance<Node2D>();
            Vector2 tilePos = walls.MapToWorld(nodePositions[i]);
            nodeInstance.Position = tilePos + positionOffset;
            walls.AddChild(nodeInstance);
            indexes.SetCellv(nodePositions[i], -1);
        }
    }

    private Array<Vector2> GetTilesInRectangle(Vector2 topLeftCell, int rectWidth, int rectHeight) {
        Array<Vector2> rectTiles = new Array<Vector2>();
        Vector2 bottomRightCell = topLeftCell + new Vector2(rectWidth, rectHeight);
        foreach (int x in GD.Range((int) topLeftCell.x, (int) bottomRightCell.x + 1)) {
            foreach (int y in GD.Range((int) topLeftCell.y, (int) bottomRightCell.y + 1)) {
                rectTiles.Add(new Vector2(x, y));
            } 
        }
        
        return rectTiles;
    }

    private Array<Vector2> GetTilesInRectCentre(Vector2 nodePos, int rectWidth, int rectHeight) {
        // Rect sides must be of uneven numbers
        Array<Vector2> rectTiles = new Array<Vector2>();
        Vector2 topLeft = nodePos - new Vector2((float) Math.Floor((float) rectWidth / 2), (float) Math.Floor((float) rectHeight / 2));
        Vector2 bottomRight = nodePos + new Vector2((float) Math.Floor((float) rectWidth / 2), (float) Math.Floor((float) rectHeight / 2));
        foreach (int x in GD.Range((int) topLeft.x, (int) bottomRight.x + 1)) {
            foreach (int y in GD.Range((int) topLeft.y, (int) bottomRight.y + 1)) {
                rectTiles.Add(new Vector2(x, y));
            }
        }

        return rectTiles;
    }
    
    private Vector2 LocationOfValue(string convertedRandomroomLocation) {
        Dictionary<string, Vector2> locations = new Dictionary<string, Vector2> {
            ["NorthwestNorth"] = roomPosNorth,
            ["North"] = roomPosNorth,
            ["NortheastNorth"] = roomPosNorth,
            
            ["NortheastEast"] = roomPosEast,
            ["East"] = roomPosEast,
            ["SouteastEast"] = roomPosEast,
            
            ["SouteastSouth"] = roomPosSouth,
            ["South"] = roomPosSouth,
            ["SouthwestSouth"] = roomPosSouth,
            
            ["SouthwestWest"] = roomPosWest,
            ["West"] = roomPosWest,
            ["NorthwestWest"] = roomPosWest,
        };
        return locations[convertedRandomroomLocation];
    }

    private TType SelectRandomFromArray<TType>(Array<TType> array) {
        array.Shuffle();
        TType firstElement = array[0];
        array.Remove(firstElement);
        return firstElement;
    }

    private Array<Vector2> SelectRandomNodePositions(Array<Vector2> nodeTileArray, int maxNodes) {
        Array<Vector2> nodePositions = new Array<Vector2>();
        if (nodeTileArray.Count < maxNodes) {
            maxNodes = nodeTileArray.Count;
        }

        foreach (int x in Enumerable.Range(0, maxNodes)) {
            nodeTileArray.Shuffle();
            if (nodeTileArray[0] != null) {
                Vector2 firstElementNodeTileArray = nodeTileArray[0];
                nodePositions.Add(firstElementNodeTileArray);
                nodeTileArray.Remove(firstElementNodeTileArray);
            }
        }

        return nodePositions;
    }

    private Vector2 SelectRandomSpawnPosition(Array<Vector2> spawnTileArray) {
        Vector2 playerSpawn = Vector2.Zero;
        Array<Vector2> possiblePlayerSpawns = new Array<Vector2>();

        foreach (Vector2 tile in spawnTileArray) {
            if (playerSpawn == Vector2.Zero) {
                playerSpawn = tile;
            }

            if (tile.y > playerSpawn.y) {
                playerSpawn = tile;
            }
        }

        foreach (Vector2 tile in spawnTileArray) {
            if (playerSpawn.y - tile.y <= 7) {
                possiblePlayerSpawns.Add(tile);
            }
        }
        possiblePlayerSpawns.Add(playerSpawn);

        return SelectRandomFromArray(possiblePlayerSpawns);
    }

    private Resource SelectItemFromDropTable(R_DropTable dropTableDef) {
        Array<R_DropTableEntry> dropTable = dropTableDef.DropTable;
        int totalDropChance = 0;
        int cumulativeDropChance = 0;
        
        foreach (R_DropTableEntry dropTableEntry in dropTable) {
            totalDropChance += dropTableEntry.DropRate;
        }

        float rng = GD.Randi() % totalDropChance;
        foreach (R_DropTableEntry dropTableEntry in dropTable) {
            cumulativeDropChance += dropTableEntry.DropRate;
            // If the RNG is <= item cumulated totalDropChance then drop that item
            if (rng <= cumulativeDropChance) {
                return dropTableEntry.Item;
            }
        }

        return null;
    }
}
