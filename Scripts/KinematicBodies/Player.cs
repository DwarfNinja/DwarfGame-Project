using Godot;
using System;
using Godot.Collections;

public class Player : KinematicBody2D {
	private const int Acceleration = 800;
	private const int MaxSpeed = 60;
	private const int Friction = 800;
	private Vector2 velocity = Vector2.Zero;
		
	private string facing = "down";

	private Node events;
	
	private Sprite playerSprite;
	private AnimationPlayer animationPlayer; 
	private AnimationTree animationTree;
	private Area2D playerInteractArea;
	private RayCast2D interactRayCast;
	private Area2D playerPickupArea;
	private Node2D inventory;

	private Resource goldcoins;
	private AnimationNodeStateMachinePlayback animationState;

	private Dictionary<string, Vector2> directionDic = new Dictionary<string, Vector2>() {
		{"up", new Vector2(0, -10)},
		{"down", new Vector2(0, 10)},
		{"left", new Vector2(-10, 0)},
		{"right", new Vector2(10, 0)},
	};
	
	
	public override void _Ready() {
		playerSprite = (Sprite) GetNode("PlayerSprite");
		animationPlayer = (AnimationPlayer) GetNode("AnimationPlayer"); 
		animationTree = (AnimationTree) GetNode("AnimationTree");
		playerInteractArea = (Area2D) GetNode("PlayerInteractArea");
		interactRayCast = (RayCast2D) GetNode("InteractRayCast");
		playerPickupArea = (Area2D) GetNode("PlayerPickupArea");
		inventory = (Node2D) GetNode("Inventory");

		goldcoins = ResourceLoader.Load("res://Resources/Entities/Resources/GoldCoins.tres");
		animationState = (AnimationNodeStateMachinePlayback) animationTree.Get("parameters/playback");
		
		playerPickupArea.Connect("body_entered", this, "_on_PlayerPickupArea_body_entered");
	}

	public override void _Process(float delta) {
		
	}
	
	public override void _PhysicsProcess(float delta) {
	  if (IsVisibleInTree()) {
		  Vector2 inputVector = Vector2.Zero;
		  //if HUD.menu_open == false:
		  inputVector.x = Input.GetActionStrength("key_right") - Input.GetActionStrength("key_left");
		  inputVector.y = Input.GetActionStrength("key_down") - Input.GetActionStrength("key_up");
		  inputVector = inputVector.Normalized();

		  if (inputVector != Vector2.Zero) {
			  animationTree.Set("parameters/Idle/blend_position", inputVector);
			  animationTree.Set("parameters/Run/blend_position", inputVector);
			  animationState.Travel("Run");
			  velocity = velocity.MoveToward(inputVector * MaxSpeed, Acceleration * delta);
		  }
		  else {
			  animationState.Travel("Idle");
			  velocity = velocity.MoveToward(Vector2.Zero, Friction * delta);
		  }

		  velocity = MoveAndSlide(velocity);
	  }

	  if (playerSprite.Frame >= 0 && playerSprite.Frame <= 7) {
		  playerInteractArea.RotationDegrees = 270; //Right
		  interactRayCast.RotationDegrees = 270;
		  facing = "right";
	  }
	  if (playerSprite.Frame != 8 && playerSprite.Frame <= 15) {
		  playerInteractArea.RotationDegrees = 90; //Left
		  interactRayCast.RotationDegrees = 90;
		  facing = "left";
	  }
	  if (playerSprite.Frame >= 16 && playerSprite.Frame <= 23) {
		  playerInteractArea.RotationDegrees = 180; //Up
		  interactRayCast.RotationDegrees = 180;
		  facing = "up";
	  }
	  if (playerSprite.Frame >= 24 && playerSprite.Frame <= 31) {
		  playerInteractArea.RotationDegrees = 0; //Down
		  interactRayCast.RotationDegrees = 0;
		  facing = "down";
	  }
	}

	private void _on_PlayerPickupArea_body_entered(Node body) {
		if ((bool) inventory.Call("can_fit_in_inventory")) {
			Events.Emit("EnteredPickupArea", this);
		}
	}
	// func _on_day_ended(tax):
	//  if Inventory.player_items[goldcoins] > 0:
	// Inventory.player_items[goldcoins] -= tax
	//  HUD.update_hud_coins(Inventory.player_items[goldcoins])
	//  else:
	// print("Game Ended")
}
