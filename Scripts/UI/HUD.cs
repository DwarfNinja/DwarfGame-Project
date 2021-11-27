using Godot;
using System;
using System.Diagnostics;

public class HUD : CanvasLayer {
    private static HUD instance;

    private Label goldCoins;
    private TextureRect travelingScreen; 
    private Timer screenTimer;
    private Label dayTimeLabel;

    public static bool MenuOpen = false;
    
    public HUD() {
        Debug.Assert(instance == null, "instance == null");
        instance = this;
    }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready() {
        goldCoins = (Label) GetNode("VBoxContainer/Labels/HBoxContainer/GoldCoins");
        travelingScreen = (TextureRect) GetNode("Control/TravelingScreen"); 
        screenTimer = (Timer) GetNode("ScreenTimer");
        dayTimeLabel = (Label) GetNode("VBoxContainer/Labels/HBoxContainer/DayTimeLabel");
        
        //Connect Signals
        screenTimer.Connect("timeout", this, nameof(OnScreenTimerTimeout));
        
        //Enter/Exit location signals
        Events.ConnectEvent(nameof(Events.ExitedCave), this, nameof(OnExitedCave));
        
        //RandomGenHouse signals
        Events.ConnectEvent(nameof(Events.RandomGenHouseLoaded), this, nameof(OnRandomgenhouseLoaded));
    }

    public static void UpdateHudCoins(int inventoryGoldcoinsAmount) {
        instance.goldCoins.Text = inventoryGoldcoinsAmount.ToString();
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
}
