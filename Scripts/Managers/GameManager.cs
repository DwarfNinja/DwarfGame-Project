using Godot;
using System;
using System.Diagnostics;
using Array = Godot.Collections.Array;
using Object = Godot.Object;

public class GameManager : Node {
    private PackedScene houseScene;

    private Node savedCaveScene;

    private int tax = 200;
    private double seconds = 0;
    private bool dayEnded = true;
    private int totalDayRealTimeSec = 900;
    private double timeSpeed = 1.5;

    private string gameTimeString = "00 : 00";
    
    [Signal]
    public delegate void CaveSceneSaved();
    
    [Signal]
    public delegate void CaveSceneLoaded();
    
    [Signal]
    public delegate void UpdatedGameTime(string gameTimeString);
    
    private static GameManager instance;

    private GameManager() {
        Debug.Assert(instance == null, "instance == null");
        instance = this;
    }
    
    public override void _Ready() {
        houseScene = (PackedScene) GD.Load("res://Scenes/Worlds/House/House.tscn");
        
        Events.ConnectEvent(nameof(Events.EnteredCave), this, nameof(OnEnteredCave));
        Events.ConnectEvent(nameof(Events.ExitedCave), this, nameof(OnExitedCave));
    }

    public override void _Process(float delta) {
        if (!dayEnded) {
            RunTime(delta);

            if (seconds >= totalDayRealTimeSec * 75) {
                Events.EmitEvent(nameof(Events.DayEnding));
            }
        }
    }
    
    // TODO: Change to be dynamic, take Scene as argument
    private void SwitchScene() {
        // Save cave scene and remove it from the tree
        EmitSignal(nameof(CaveSceneSaved));
        savedCaveScene = GetTree().Root.GetNode("Cave");
        GetTree().Root.RemoveChild(savedCaveScene);
        // Instance and add HouseScene as current scene
        Node HouseSceneInstance = houseScene.Instance();
        GetTree().Root.AddChild(HouseSceneInstance);
        GetTree().CurrentScene = HouseSceneInstance;
    }

    private void LoadScene() {
        if (!GetTree().Root.HasNode("Cave")) {
            // Free current scene
            GetTree().Root.AddChild(savedCaveScene);
            GetTree().CurrentScene = savedCaveScene;
        }
        // Add saved scene back to tree
        if (GetTree().CurrentScene == savedCaveScene) {
            GetTree().Root.GetNode("House").QueueFree();
            EmitSignal(nameof(CaveSceneLoaded));
        }
        else {
            LoadScene();
        }
    }

    private void SaveScene(Node nodeToSave) {
        string filePath = "res://your_scene.tscn";
        PackedScene newPackedScene = new PackedScene();
        newPackedScene.Pack(nodeToSave);
        ResourceSaver.Save(filePath, newPackedScene);
    }

    private void RunTime(float delta) {
        double minutes = seconds / 60;

        if ((int) seconds == totalDayRealTimeSec) {
            EndDay();
        }

        seconds += delta * timeSpeed;
        int gameHours =  (int) minutes + 7 % 24;
        int gameMinutes = (int) seconds % 60;
        string timeFormatted = gameHours + " : " + gameMinutes;
        
        EmitSignal(nameof(UpdatedGameTime), timeFormatted);
    }

    private void EndDay() {
        dayEnded = true;
        Events.EmitEvent(nameof(Events.DayEnded), tax);
    }
    
    private void StartDay() {
        seconds = 0;
        dayEnded = false;
        Events.EmitEvent(nameof(Events.DayStarted));
    }


    private void OnEnteredCave() {
        // Loading Cave and freeing House Scene
        LoadScene();
    }
    
    private void OnExitedCave() {
        // Saving Cave Scene and instancing House Scene
        SwitchScene();  
    }
}
