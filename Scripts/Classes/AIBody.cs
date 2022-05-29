using Godot;
using System;
using Godot.Collections;
using Array = Godot.Collections.Array;

public class AIBody : KinematicBody2D {

    [Export] 
    private R_AI aiDef;

    private string nodeName;
    private Sprite aiSprite;
    protected Area2D visionConeArea;
    
    private Vector2 direction = Vector2.Zero;
    private const int Acceleration = 300;
    private const int MaxSpeed = 20; // was 30
    protected const int Friction = 300;
    protected Vector2 velocity = Vector2.Zero;

    protected Villager.States state;

    public Vector2 lastknownPlayerposition;
    protected Node2D target;
    private Vector2? targetPos;

    protected bool playerInVisioncone;
    protected bool canSeeTarget;
    protected Array<Vector2> hitPos = new Array<Vector2>();

    public Vector2 SpawnPosition;
    public Vector2? randomRoamCell;

    public Array<Vector2> path = new Array<Vector2>();
    protected bool reachedEndOfPath;
    
    public override void _Ready() {
        aiSprite = GetNode<Sprite>("AISprite");
        visionConeArea = GetNode<Area2D>("VisionConeArea");
        visionConeArea.Connect("body_entered", this, nameof(OnVisionConeAreaBodyEntered));
        visionConeArea.Connect("body_exited", this, nameof(OnVisionConeAreaBodyExited));

        if (aiDef == null) {
            aiSprite.Texture = null;
            GD.PushError("ERROR: No aiDef defined in AI: " + this);
            return;
        }

        SetAI();
    }

    public override void _Process(float delta) {
        Update();
    }

    private void SetAI() {
        if (aiSprite == null) {
            return;
        }

        aiSprite.Texture = aiDef.AiSpriteSheet;
    }

    protected void SetTarget(Vector2? newTargetPos) {
        if (targetPos != null) {
            if (newTargetPos != targetPos) {
                targetPos = newTargetPos;
                UpdatePath();
            }

            if (path == null) {
                UpdatePath();
            }
        }
        
        else if (newTargetPos != null) {
            targetPos = newTargetPos;
            UpdatePath();
        }
        else {
            GD.PushError("ERROR: Paramater newTargetPos is null in AI: " + this);
        }
    }

    protected void SetLastknownPlayerposition(Vector2 newPlayerPosition) {
        if (lastknownPlayerposition != newPlayerPosition) {
            lastknownPlayerposition = newPlayerPosition;
        }
        Events.EmitEvent(nameof(Events.UpdateLastKnownPlayerPosition), lastknownPlayerposition, state);
    }

    protected void AimRaycasts() {
        if (playerInVisioncone) {
            hitPos.Clear();
            Physics2DDirectSpaceState spaceState = GetWorld2d().DirectSpaceState;
            CollisionShape2D targetCollisionShape = target.GetNode<CollisionShape2D>("CollisionShape2D");
            Vector2 targetExtents = new Vector2((float) targetCollisionShape.Shape.Get("radius"),
                (float) targetCollisionShape.Shape.Get("height")) - new Vector2(5, 5);
            Vector2 nw = target.Position - targetExtents;
            Vector2 se = target.Position + targetExtents;
            Vector2 ne = target.Position + new Vector2(targetExtents.x, -targetExtents.y);
            Vector2 sw = target.Position + new Vector2(-targetExtents.x, targetExtents.y);
            Array<Vector2> positions = new Array<Vector2> { target.Position, nw, se, ne, sw};
            
            foreach (Vector2 position in positions) {
                Dictionary result = spaceState.IntersectRay(visionConeArea.GlobalPosition, position, new Array {this}, 0b100001);
                if (result != null) {
                    if (result.Contains("position")) {
                        hitPos.Add((Vector2) result["position"]);
                    }
                    
                    if (result.Contains("collider")) {
                        if (((Node2D) result["collider"]).Name == target.Name) {
                            canSeeTarget = true;
                            SetLastknownPlayerposition(target.GlobalPosition);
                        }
                        
                        else {
                            canSeeTarget = false;
                        }
                    }
                }
            }
        }
        else {
            canSeeTarget = false;
        }
    }

    protected void MoveAlongPath(float delta) {
        Vector2 startingPoint = GlobalPosition;
        float moveDistance = MaxSpeed * delta;

        for(int i = 0; i < path.Count; i++) {
            reachedEndOfPath = false;
            float distanceToNextPoint = startingPoint.DistanceTo(path[0]);
            if (moveDistance <= distanceToNextPoint) {
                float moveRotation = GetAngleTo(startingPoint.LinearInterpolate(path[0], moveDistance / distanceToNextPoint));
                Vector2 direction = new Vector2((float) Math.Cos(moveRotation), (float) Math.Sin(moveRotation));
                velocity = velocity.MoveToward(direction * MaxSpeed, Acceleration * delta);
                MoveAndSlide(velocity);
                break;
            }

            moveDistance -= distanceToNextPoint;
            startingPoint = path[0];
            path.RemoveAt(0);
        }

        if (path.Count == 0) {
            reachedEndOfPath = true;
        }
    }

    protected void ChaseTarget(float delta) {
        if (target != null) {
            float distance = GlobalPosition.DistanceTo(target.GlobalPosition);

            if (distance > 3) {
                direction = (target.GlobalPosition - GlobalPosition).Normalized();
                velocity = velocity.MoveToward(direction * MaxSpeed, Acceleration * delta);
                MoveAndSlide(velocity);
            }
        }
    }
    
    private void UpdatePath() {
        Events.EmitEvent(nameof(Events.RequestNavPath), this, targetPos);
    }

    private void OnVisionConeAreaBodyEntered(Node2D body) {
        if (body.Name == "Player") {
            target = body;
            targetPos = body.GlobalPosition;
            playerInVisioncone = true;
        }
    }
    
    private void OnVisionConeAreaBodyExited(Node2D body) {
        if (body.Name == "Player") {
            target = null;
            targetPos = null;
            playerInVisioncone = false;
        }
    }

    public override void _Draw() {
        Color laserColor = new Color((float) 1.0, (float) .329, (float) .298);

        if (playerInVisioncone) {
            foreach (Vector2 hit in hitPos) {
                DrawCircle((hit - Position).Rotated(-Rotation), 1, laserColor);
                DrawLine(visionConeArea.Position, (hit - Position).Rotated(-Rotation), laserColor);
            }
        }
    }
}
