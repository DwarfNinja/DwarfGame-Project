using Godot;
using System;
using Godot.Collections;
using Array = Godot.Collections.Array;

public class Player : KinematicBody2D {
    private const int Acceleration = 800;
    private const int MaxSpeed = 60;
    private const int Friction = 800;
    private Vector2 velocity = Vector2.Zero;
		
    private string facing = "down";

    private Sprite playerSprite;
    private AnimationTree animationTree;
    private Area2D interactArea;
    private Node2D interactAreaAnchor;
    private Area2D playerPickupArea;
    private Inventory inventory;
	
    private AnimationNodeStateMachinePlayback animationState;
	
    private Vector2 inputVector = Vector2.Zero;

    private Array<Vector2> collisionPositions = new Array<Vector2>();
    private Array<InteractableEntity> interactablesInArea = new Array<InteractableEntity>();

    private InteractableEntity closestInteractable = null;

    private Dictionary<string, Vector2> directionDic = new Dictionary<string, Vector2> {
        ["up"] = new Vector2(0, -10),
        ["down"] = new Vector2(0, 10),
        ["left"] = new Vector2(-10, 0),
        ["right"] = new Vector2(10, 0)
    };
	
    public override void _Ready() {
        playerSprite = (Sprite) GetNode("PlayerSprite");
        animationTree = (AnimationTree) GetNode("AnimationTree");
        interactArea = (Area2D) GetNode("InteractAreaAnchor/InteractArea");
        interactAreaAnchor = (Node2D) GetNode("InteractAreaAnchor");
        playerPickupArea = (Area2D) GetNode("PlayerPickupArea");
        inventory = (Inventory) GetNode("Inventory");
        animationState = (AnimationNodeStateMachinePlayback) animationTree.Get("parameters/playback");
		
        playerPickupArea.Connect("body_entered", this, nameof(OnPlayerPickupAreaBodyEntered));
        interactArea.Connect("body_entered", this, nameof(OnInteractAreaBodyEntered));
        interactArea.Connect("body_exited", this, nameof(OnInteractAreaBodyExited));
    }

    public override void _UnhandledInput(InputEvent @event) {
        inputVector.x = @event.GetActionStrength("key_right") - @event.GetActionStrength("key_left");
        inputVector.y = @event.GetActionStrength("key_down") - @event.GetActionStrength("key_up");
        inputVector = inputVector.Normalized();
		
        if (@event.IsActionPressed("key_e")) {
            closestInteractable?.Interact(this);
        }
    }

    public override void _Process(float delta) {
        // Update();
    }

    public override void _PhysicsProcess(float delta) { 
        if (IsVisibleInTree()) {
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
            interactAreaAnchor.RotationDegrees = 270;
            facing = "right";
        }
        if (playerSprite.Frame >= 8 && playerSprite.Frame <= 15) {
            interactAreaAnchor.RotationDegrees = 90;
            facing = "left";
        }
        if (playerSprite.Frame >= 16 && playerSprite.Frame <= 23) {
            interactAreaAnchor.RotationDegrees = 180;
            facing = "up";
        }
        if (playerSprite.Frame >= 24 && playerSprite.Frame <= 31) {
            interactAreaAnchor.RotationDegrees = 0;
            facing = "down";
        }
        
        CheckVisibleInteractables();
    }

    private void CheckVisibleInteractables() {
        collisionPositions.Clear();
        if (interactablesInArea.Count > 0) {
            Array<InteractableEntity> visibleInteractables = GetVisibleInteractables();
            InteractableEntity closestInteractable = GetClosestInteractable(visibleInteractables);
            closestInteractable.InteractingBodyEntered();
        }
    }
    
    private Array<InteractableEntity> GetVisibleInteractables() {
        Array<InteractableEntity> visibleInteractables = new Array<InteractableEntity>();
        Physics2DDirectSpaceState directState = GetWorld2d().DirectSpaceState;
        foreach (InteractableEntity interactable in interactablesInArea) {
            CollisionShape2D closestInteractableCollisionShape = (CollisionShape2D) interactable.GetNode("CollisionShape2D");
            
            Dictionary collision = directState.IntersectRay(GlobalPosition,
                closestInteractableCollisionShape.GlobalPosition, new Array(this), 0b1000);
            if (collision.Contains("collider")) {
                if (collision["collider"] == interactable) {
                    visibleInteractables.Add(interactable);
                    collisionPositions.Add((Vector2) collision["position"]);
                }
            }
        }

        return visibleInteractables;
    }

    private InteractableEntity GetClosestInteractable(Array<InteractableEntity> interactablesArray) {
        closestInteractable = null;
        foreach (InteractableEntity interactable in interactablesArray) {
            closestInteractable ??= interactable;
            CollisionShape2D closestInteractableCollisionShape = (CollisionShape2D) interactable.GetNode("CollisionShape2D");
            CollisionShape2D interactableCollisionShape = (CollisionShape2D) interactable.GetNode("CollisionShape2D");
            
            if (interactableCollisionShape.GlobalPosition.DistanceTo(GlobalPosition) <
                closestInteractableCollisionShape.GlobalPosition.DistanceTo(GlobalPosition)) {
                closestInteractable.InteractingBodyExited();
                closestInteractable = interactable;
            }
        }
        return closestInteractable;
    }

    public Inventory Inventory => inventory;

    private void OnPlayerPickupAreaBodyEntered(PickableItem item) {
        if (inventory.CanFitInInventory(item.ItemDef)) {
            item.EnteredPickupArea(this);
        }
    }

    private void OnInteractAreaBodyEntered(Node2D body) {
        if (body is InteractableEntity interactableEntity) {
            if (!interactablesInArea.Contains(interactableEntity)) {
                interactablesInArea.Add(interactableEntity);
            }
        }
    }
	
    private void OnInteractAreaBodyExited(Node2D body) {
        if (body is InteractableEntity interactableEntity) {
            if (interactablesInArea.Contains(interactableEntity)) {
                interactablesInArea.Remove(interactableEntity);
                interactableEntity.InteractingBodyExited();
            }
        }
    }

    // public override void _Draw() {
    //     Color laserColour = new Color((float) 1.0, (float) 0.329, (float) 0.298);
    //
    //     foreach (Vector2 collision in collisionPositions) {
    //         DrawCircle((collision - Position).Rotated(-Rotation), 1, laserColour);
    //         DrawLine(interactAreaAnchor.Position, (collision - Position).Rotated(-Rotation), laserColour);
    //     }
    // }
}