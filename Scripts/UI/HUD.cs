using Godot;
using System;

public class HUD : CanvasLayer {

    private Label goldCoins;
    private TextureRect travelingScreen; 
    private Timer screenTimer;
    private Label dayTimeLabel;

    public static bool MenuOpen = false;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready() {
        goldCoins = (Label) GetNode("VBoxContainer/Labels/HBoxContainer/GoldCoins");
        travelingScreen = (TextureRect) GetNode("UIs/TravelingScreen"); 
        screenTimer = (Timer) GetNode("ScreenTimer");
        dayTimeLabel = (Label) GetNode("VBoxContainer/Labels/HBoxContainer/DayTimeLabel");
        
        //Connect Signals
        screenTimer.Connect("timeout", this, nameof(OnScreenTimerTimeout));
        Events.ConnectEvent(nameof(Events.UpdateHudCoins), this, nameof(OnUpdateHudCoins));
        //Enter/Exit location signals
        Events.ConnectEvent(nameof(Events.ExitedCave), this, nameof(OnExitedCave));
        //RandomGenHouse signals
        Events.ConnectEvent(nameof(Events.RandomGenHouseLoaded), this, nameof(OnRandomgenhouseLoaded));
        
        GameManager.ConnectEvent(nameof(GameManager.UpdatedGameTime), this, nameof(OnUpdatedGameTime));
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
        double minutes = seconds / 60;
        double gameHours =  minutes + dayStartTime % 24;
        double gameMinutes = seconds % 60;
        
        string formattedTime = $"{gameHours:00} : {gameMinutes:00}";
        
        // Localised Time format
        // string timeFormatted = new DateTime(2000, 1, 1, gameHours, gameMinutes, 0).ToString("t");
        
        dayTimeLabel.Text = formattedTime;
    }
}
