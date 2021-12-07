using Godot;
using System;
using System.Diagnostics;

public class HUD : CanvasLayer {

    private Label goldCoins;
    private TextureRect travelingScreen; 
    private Timer screenTimer;
    private Label dayTimeLabel;

    public static bool MenuOpen = false;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready() {
        goldCoins = (Label) GetNode("VBoxContainer/Labels/HBoxContainer/GoldCoins");
        travelingScreen = (TextureRect) GetNode("Control/TravelingScreen"); 
        screenTimer = (Timer) GetNode("ScreenTimer");
        dayTimeLabel = (Label) GetNode("VBoxContainer/Labels/HBoxContainer/DayTimeLabel");
        
        //Connect Signals
        screenTimer.Connect("timeout", this, nameof(OnScreenTimerTimeout));
        Events.ConnectEvent(nameof(Events.UpdateHudCoins), this, nameof(OnUpdateHudCoins));
        //Enter/Exit location signals
        Events.ConnectEvent(nameof(Events.ExitedCave), this, nameof(OnExitedCave));
        //RandomGenHouse signals
        Events.ConnectEvent(nameof(Events.RandomGenHouseLoaded), this, nameof(OnRandomgenhouseLoaded));
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
}
