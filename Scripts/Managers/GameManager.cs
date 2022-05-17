using Godot;
using System;
using System.Diagnostics;
using Godot.Collections;
using Array = Godot.Collections.Array;
using Object = Godot.Object;

public class GameManager : Node {
    private PackedScene houseScene;

    private Node savedCaveScene;
    private Dictionary<string, Node> tempCachedScenes = new Dictionary<string, Node> {
        ["Cave"] = null
    };

    private int tax = 200;
    private double seconds = 0;
    private bool dayEnded = true;
    private int totalDayDuration = 900;
    private double timeSpeed = 1.5;
    private int dayStartTime = 7;

    private string gameTimeString = "00 : 00";

    [Signal]
    public delegate void UpdatedGameTime(double seconds, int dayStartTime);

    private static GameManager instance;

    private GameManager() {
        Debug.Assert(instance == null, "instance == null");
        instance = this;
    }
    
    public override void _Ready() {
        houseScene = (PackedScene) GD.Load("res://Scenes/Worlds/House/House.tscn");
        
        Events.ConnectEvent(nameof(Events.StartNewGame), this, nameof(OnStartNewGame));
        Events.ConnectEvent(nameof(Events.EnteredCave), this, nameof(OnEnteredCave));
        Events.ConnectEvent(nameof(Events.ExitedCave), this, nameof(OnExitedCave));
        
        GD.Randomize();
    }

    public override void _Process(float delta) {
        if (!dayEnded) {
            RunTime(delta);

            if (seconds >= totalDayDuration * 75) {
                Events.EmitEvent(nameof(Events.DayEnding));
            }
        }
    }

    private Node LoadCachedScene(string nodeName) {
        if (tempCachedScenes.ContainsKey(nodeName)) {
            Node savedScene = tempCachedScenes[nodeName];
            GetTree().Root.AddChild(savedScene);
            return savedScene;
        }

        GD.PushError("Can't load scene from cache. Scene: " + nodeName + " does not exist!");
        return null;
    }

    //Implemented for later use
    private void SaveScene(Node nodeToSave) {
        string filePath = "user://User-" + nodeToSave.Name + ".tscn";
        PackedScene newPackedScene = new PackedScene();
        newPackedScene.Pack(nodeToSave);
        ResourceSaver.Save(filePath, newPackedScene);
    }
    
    private PackedScene LoadScene(string sceneName) {
        string filePath = "user://User-" + sceneName + ".tscn";
        PackedScene loadedScene = ResourceLoader.Load<PackedScene>(filePath, "PackedScene");
        return loadedScene;
    }

    private void TempCacheScene(Node nodeToSave) {
        if (tempCachedScenes.ContainsKey(nodeToSave.Name)) {
            tempCachedScenes[nodeToSave.Name] = nodeToSave;
        }
        else {
            tempCachedScenes.Add(nodeToSave.Name, nodeToSave);
        }
        GetTree().Root.RemoveChild(nodeToSave);
    }
    
    private void SwitchScene(Node nodeToSwitchTo) {
        Node oldScene = GetTree().CurrentScene;
        GetTree().CurrentScene = nodeToSwitchTo;
        oldScene.QueueFree();
    }

    private void RunTime(float delta) {
        if ((int) Math.Round(seconds) == totalDayDuration) {
            EndDay();
        }
        seconds += delta * timeSpeed;
        EmitSignal(nameof(UpdatedGameTime), seconds, dayStartTime); 
    }

    private void StartDay() {
        seconds = 0;
        dayEnded = false;
        Events.EmitEvent(nameof(Events.DayStarted));
    }

    private void EndDay() {
        dayEnded = true;
        Events.EmitEvent(nameof(Events.DayEnded), tax);
    }
    
    private void OnStartNewGame() {
        GetTree().ChangeScene("res://Scenes/Worlds/Cave/Cave.tscn");
    }

    private void OnEnteredCave() {
        // Loading Cave and freeing House Scene
        Node cachedCaveScene = LoadCachedScene("Cave");
        SwitchScene(cachedCaveScene);
    }
    
    private void OnExitedCave() {
        dayEnded = false;
        // Saving Cave Scene and instancing House Scene
        Node2D caveScene = (Node2D) GetTree().Root.GetNode("Cave");
        TempCacheScene(caveScene);
        
        // Instance and add HouseScene as current scene
        Node houseSceneInstance = houseScene.Instance();
        GetTree().Root.AddChild(houseSceneInstance);
        GetTree().CurrentScene = houseSceneInstance;
    }

    public static void ConnectEvent(string signal, Object target, string method, Array binds = null, uint flags = 0U) {
        instance.Connect(signal, target, method, binds, flags);
    }
    
    public static void DisconnectEvent(string signal, Object target, string method) {
        instance.Disconnect(signal, target, method);
    }
}
