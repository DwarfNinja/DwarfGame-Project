using Godot;
using System;
using System.Diagnostics;
using Godot.Collections;
using Array = Godot.Collections.Array;
using Object = Godot.Object;

public class Events : Node {
    private static Events instance;

    private Events() {
        Debug.Assert(instance == null, "instance == null");
        instance = this;
    }
    
    //Game signals
    [Signal]
    public delegate void StartNewGame();

    //Item pickup/inventory signals
    [Signal]
    public delegate void PlaceObject(R_Item selectedItem);
    [Signal]
    public delegate void RemoveSelectedItem(R_Item selectedItem);
    [Signal]
    public delegate void DropSelectedItem(R_Item selectedItem);
    
    [Signal]
    public delegate void UpdateSlot(Slot slot);
    
    [Signal]
    public delegate void UpdateSelector(Slot slot, bool selecting);
    
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
    public delegate void CraftItem(R_Craftable craftableDef);

    //Forge signals
    [Signal]
    public delegate void OpenForge(Forge forge, Player interactingPlayer);
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
    public delegate void UpdateLastKnownPlayerPosition(Vector2 lastKnownPlayerPosition, Villager.States state);
    
    [Signal]
    public delegate void UpdateHudCoins(int inventoryGoldcoinsAmount);

    public static void EmitEvent(string signal, params object[] args) {
        instance.EmitSignal(signal, args);
    }
    
    public static void ConnectEvent(string signal, Object target, string method, Array binds = null, uint flags = 0U) {
        instance.Connect(signal, target, method, binds, flags);
    }
    
    public static void DisconnectEvent(string signal, Object target, string method) {
        instance.Disconnect(signal, target, method);
    }
}
