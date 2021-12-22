using Godot;
using System;
using System.Diagnostics;
using DwarfGameProject.Scripts.Nodes;
using Godot.Collections;
using Array = Godot.Collections.Array;
using Object = Godot.Object;

public class Events : Node {
    private static Events instance;

    private Events() {
        Debug.Assert(instance == null, "instance == null");
        instance = this;
    }

    //Item pickup/inventory signals
    [Signal]
    public delegate void PlaceObject(RW_Item selectedItem);
    [Signal]
    public delegate void RemoveSelectedItem(RW_Item selectedItem);
    [Signal]
    public delegate void DropSelectedItem(RW_Item selectedItem);

    [Signal]
    public delegate void UpdateSlotSelectors(int selectorPosition, Dictionary selectedSlot);
    [Signal]
    public delegate void UpdateSlot(Slot slot);
    
    [Signal]
    public delegate void EnteredPickupArea(PickableItem item, Node2D target);
    [Signal]
    public delegate void ExitedPickupArea(PickableItem item, Node2D target);

    //CraftingTable signals
    [Signal]
    public delegate void OpenCraftingTable();
    [Signal]
    public delegate void CloseCraftingTable();
    
    [Signal]
    public delegate void CraftItem(RW_Craftable craftableDef);

    //Forge signals
    [Signal]
    public delegate void OpenForge(Node2D currentOpenedForge);
    [Signal]
    public delegate void CloseForge();
    [Signal]
    public delegate void IronAmountSet(Node2D currentOpenedForge, int sliderIronAmount);
    
    //Shop signals
    [Signal]
    public delegate void EnteredShop();
    [Signal]
    public delegate void ExitedShop();
    
    //BlackMarket signals
    [Signal]
    public delegate void EnteredBlackMarket();
    [Signal]
    public delegate void ExitedBlackMarket();

    //Day signals
    [Signal]
    public delegate void DayStarted();
    [Signal]
    public delegate void DayEnding();
    [Signal]
    public delegate void DayEnded(int tax);
    
    //Mouse entered CraftingTableButton signal
    [Signal]
    public delegate void CraftingButtonMouseEntered();

    //Cave signals
    [Signal]
    public delegate void EnteredCave();
    [Signal]
    public delegate void ExitedCave();

    //RandomGenHouse signals
    [Signal]
    public delegate void RandomGenHouseLoaded();
    
    [Signal]
    public delegate void RequestNavPath(Node2D body, Vector2 target);
    [Signal]
    public delegate void RequestRoamCell(Node2D body);
    
    [Signal]
    public delegate void UpdateLastKnownPlayerPosition(Vector2 lastKnownPlayerPosition, int state);
    
    [Signal]
    public delegate void UpdateHudCoins(int inventoryGoldcoinsAmount);

    public static void EmitEvent(string signal, params object[] args) {
        instance.EmitSignal(signal, args);
    }
    
    public static void ConnectEvent(string signal, Object target, string method, Array binds = null, uint flags = 0U) {
        instance.Connect(signal, target, method, binds, flags);
    }
}
