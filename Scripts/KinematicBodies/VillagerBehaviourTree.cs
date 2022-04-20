using System;
using BehaviourTree;
using BehaviourTree.FluentBuilder;
using Godot;
using Godot.Collections;

public class VillagerBehaviourTree : KinematicBody2D {
    
    private Vector2 direction = Vector2.Zero;
    private const int Acceleration = 300;
    private const int MaxSpeed = 20; // was 30
    protected const int Friction = 300;
    protected Vector2 velocity = Vector2.Zero;
    
    private RayCast2D rayCast2DLeft;
    private RayCast2D rayCast2DRight;
    private Area2D visionConeArea;
    
    private int raycastInversion = 1;
    
    public Array<Vector2> path = new Array<Vector2>();

    private IBehaviour<BtContext> behaviourTree;

    private AiBlackboard aiBlackboard;

    public override void _Ready() {
        rayCast2DLeft = GetNode<RayCast2D>("VisionConeArea/RayCast2DLeft");
        rayCast2DRight = GetNode<RayCast2D>("VisionConeArea/RayCast2DRight");
        visionConeArea = GetNode<Area2D>("VisionConeArea");

        behaviourTree = FluentBuilder.Create<BtContext>()
            .Sequence("root")
                .Selector("can see target")
            .Do("move to target", MoveToTarget)
            .RandomSelector("select state")
                .Subtree(IdleBehaviour())
                .Subtree(RoamBehaviour())
            .End()
            .Build();
    }

    public override void _PhysicsProcess(float delta) {
        behaviourTree.Tick(new BtContext(this, aiBlackboard, delta));
    }
    
    private IBehaviour<BtContext> IdleBehaviour() {
        
        return FluentBuilder.Create<BtContext>()
            .Sequence("idle behaviour")
                .Do("idle scan visioncone", ScanVisionCone)
            .End()
            .Build();
    }

    private BehaviourStatus ScanVisionCone(BtContext context) {

        if (rayCast2DLeft.IsColliding()) {
            raycastInversion = -1;
        }
        else if (rayCast2DRight.IsColliding()) {
            raycastInversion = 1;
        }
        
        visionConeArea.Rotation += (float) 0.01 * raycastInversion;
        return BehaviourStatus.Running;
    }
    
    private BehaviourStatus MoveToTarget(BtContext context) {
        int raycastInversion = 1;
        
        if (rayCast2DLeft.IsColliding()) {
            raycastInversion = -1;
        }
        else if (rayCast2DRight.IsColliding()) {
            raycastInversion = 1;
        }
        
        visionConeArea.Rotation += (float) 0.01 * raycastInversion;
        return BehaviourStatus.Running;
    }
    
    private BehaviourStatus MoveToRoamCell(BtContext context) {
        Vector2 startingPoint = GlobalPosition;
        float moveDistance = MaxSpeed * context.DeltaTime;

        for(int i = 0; i < path.Count; i++) {
            float distanceToNextPoint = startingPoint.DistanceTo(path[0]);
            if (moveDistance <= distanceToNextPoint) {
                float moveRotation = GetAngleTo(startingPoint.LinearInterpolate(path[0], moveDistance / distanceToNextPoint));
                Vector2 direction = new Vector2((float) Math.Cos(moveRotation), (float) Math.Sin(moveRotation));
                velocity = velocity.MoveToward(direction * MaxSpeed, Acceleration * context.DeltaTime);
                MoveAndSlide(velocity);
                break;
            }

            moveDistance -= distanceToNextPoint;
            startingPoint = path[0];
            path.RemoveAt(0);
        }

        if (path.Count == 0) {
            return BehaviourStatus.Succeeded;
        }
        return BehaviourStatus.Running;
    }

    private IBehaviour<BtContext> RoamBehaviour() {
        
        return FluentBuilder.Create<BtContext>()
            .Sequence("roam behaviour")
                .Do("move to roamcell", MoveToRoamCell)
                .Do("move to spawncell", MoveToRoamCell)
            .End()
            .Build();
        
        // switch (roamState) {
        //     case "RoamToRandomCell":
        //         SetTarget(randomRoamCell);
        //         MoveAlongPath(delta);
        //         break;
        //                 
        //     case "RoamToSpawnCell":
        //         SetTarget(SpawnPosition);
        //         MoveAlongPath(delta);
        //         break;
        // }
        //         
        // if (reachedEndOfPath) {
        //     roamDelayTimer.Start();
        //     state = States.Idle;
        // }
        //
        // if (canSeeTarget) {
        //     Detect();
        //     velocity = velocity.MoveToward(Vector2.Zero, Friction * delta);
        // }
        // else {
        //     AngleVisionCone(velocity.Normalized(), (float) 0.05);
        // }
    }
}