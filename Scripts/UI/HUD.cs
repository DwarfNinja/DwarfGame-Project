using Godot;
using System;
using System.Diagnostics;

public class HUD : CanvasLayer {

    private VBoxContainer vBoxContainer;

    private Label goldCoins;
    private Timer screenTimer;
    private Label dayTimeLabel;
    
    private TextureRect travelingScreen; 

    private CraftingTableUI craftingTableUi;
    private ForgeUI forgeUi;

    public static bool MenuOpen = false;
    
    private static HUD instance;

    private HUD() {
        Debug.Assert(instance == null, "instance == null");
        instance = this;
    }
    
    public override void _Ready() {
        vBoxContainer = GetNode<VBoxContainer>("VBoxContainer"); 
        
        goldCoins = GetNode<Label>("VBoxContainer/Labels/HBoxContainer/GoldCoins");
        travelingScreen = GetNode<TextureRect>("UIs/TravelingScreen"); 
        screenTimer = GetNode<Timer>("ScreenTimer");
        dayTimeLabel = GetNode<Label>("VBoxContainer/Labels/HBoxContainer/DayTimeLabel");

        craftingTableUi = GetNode<CraftingTableUI>("UIs/CraftingTableUI"); 
        forgeUi = GetNode<ForgeUI>("UIs/ForgeUI"); 
        
        //Connect Signals
        screenTimer.Connect("timeout", this, nameof(OnScreenTimerTimeout));
        
        craftingTableUi.Connect("popup_hide", this, nameof(OnPopUpHide));
        
        forgeUi.Connect("popup_hide", this, nameof(OnPopUpHide));
        
        Events.ConnectEvent(nameof(Events.StartNewGame), this, nameof(OnStartNewGame));
        
        Events.ConnectEvent(nameof(Events.UpdateHudCoins), this, nameof(OnUpdateHudCoins));
        //Enter/Exit location signals
        Events.ConnectEvent(nameof(Events.ExitedCave), this, nameof(OnExitedCave));
        //RandomGenHouse signals
        Events.ConnectEvent(nameof(Events.RandomGenHouseLoaded), this, nameof(OnRandomgenhouseLoaded));

        GameManager.ConnectEvent(nameof(GameManager.UpdatedGameTime), this, nameof(OnUpdatedGameTime));
        
        Events.ConnectEvent(nameof(Events.OpenForge), this, nameof(OnOpenForge));
        
        Events.ConnectEvent(nameof(Events.OpenCraftingTable), this, nameof(OnOpenCraftingTable));
    }

    private void OnStartNewGame() {
        vBoxContainer.Show();
        MenuOpen = false;
    }
    
    private void OnExitedCave() {
        //GameManager.day_ended = false
        travelingScreen.Visible = true;
    }

    private void OnRandomgenhouseLoaded() {
        screenTimer.Start();
    }

    private void OnScreenTimerTimeout() {
        travelingScreen.Visible = false;
    }
    
    private void OnUpdateHudCoins(int inventoryGoldcoinsAmount) {
        goldCoins.Text = inventoryGoldcoinsAmount.ToString();
    }

    private void OnUpdatedGameTime(double seconds, int dayStartTime) {
        int intSeconds = (int) Math.Round(seconds);
        int minutes = intSeconds / 60;
        int gameHours =  minutes + dayStartTime % 24;
        int gameMinutes = intSeconds % 60;

        string formattedTime = $"{gameHours:00} : {gameMinutes:00}";
        
        // Localised Time format
        // string timeFormatted = new DateTime(2000, 1, 1, gameHours, gameMinutes, 0).ToString("t");
        
        dayTimeLabel.Text = formattedTime;
    }
    
    public void OnOpenCraftingTable() {
        craftingTableUi.OpenCraftingTableUI();
        MenuOpen = true;
    }

    public void OnOpenForge(Forge forge, Player interactingBody) {
        forgeUi.OpenForgeUI(forge, interactingBody);
        MenuOpen = true;
    }

    private void OnPopUpHide() {
        MenuOpen = false;
    }
}
