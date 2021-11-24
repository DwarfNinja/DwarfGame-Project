using Godot;
using System;
using System.Diagnostics;
using Godot.Collections;
using Object = Godot.Object;

public class Events : Node {
    private static Events _instance;

    public Events() {
        Debug.Assert(_instance == null, "_instance == null");
        _instance = this;
    }
    
    //Item pickup/inventory signals
    [Signal]
    private delegate void ItemPickedUp(Resource itemDef);
    [Signal]
    private delegate void PlaceObject(Resource selectedItem);
    [Signal]
    private delegate void RemoveItem(Resource selectedItem);
    [Signal]
    private delegate void DropItem(Resource selectedItem);

    [Signal]
    private delegate void UpdateSlotSelectors(int selectorPosition, Dictionary selectedSlot);
    [Signal]
    private delegate void UpdateSlot(string slot, Resource itemDef, int count);
    
    [Signal]
    private delegate void EnteredPickupArea(Node target);
    [Signal]
    private delegate void ExitedPickupArea(Node target);

    //CraftingTable signals
    [Signal]
    private delegate void OpenCraftingTable();
    [Signal]
    private delegate void CloseCraftingTable();
    
    [Signal]
    private delegate void CraftItem(Resource craftableDef);

    //Forge signals
    [Signal]
    private delegate void OpenForge(Node2D currentOpenedForge);
    [Signal]
    private delegate void CloseForge();
    [Signal]
    private delegate void IronAmountSet(Node2D currentOpenedForge, int sliderIronAmount);
    
    //Shop signals
    [Signal]
    private delegate void EnteredShop();
    [Signal]
    private delegate void ExitedShop();
    
    //BlackMarket signals
    [Signal]
    private delegate void EnteredBlackMarket();
    [Signal]
    private delegate void ExitedBlackMarket();

    //Day signals
    [Signal]
    private delegate void DayStarted();
    [Signal]
    private delegate void DayEnding();
    [Signal]
    private delegate void DayEnded(int tax);
    
    //Mouse entered CraftingTableButton signal
    [Signal]
    private delegate void CraftingButtonMouseEntered();

    //Cave signals
    [Signal]
    private delegate void EnteredCave();
    [Signal]
    private delegate void ExitedCave();

    //RandomGenHouse signals
    [Signal]
    private delegate void RandomGenHouseLoaded();
    
    [Signal]
    private delegate void RequestNavPath(Node2D body, Vector2 target);
    [Signal]
    private delegate void RequestRoamCell(Node2D body);
    
    [Signal]
    private delegate void UpdateLastKnownPlayerPosition(Vector2 lastKnownPlayerPosition, int state);

    public static void Emit(string signal, params object[] args) {
        _instance.EmitSignal(signal, args);
    }
}
