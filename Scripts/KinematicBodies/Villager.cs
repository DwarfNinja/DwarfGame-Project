using Godot;
using System;
using Godot.Collections;

public class Villager : AIBody {

    private Timer detectionTimer;
    private Timer stateDurationTimer;
    private Timer reactionTimer;
    private Timer roamDelayTimer;
    private RayCast2D rayCastN1;
    private RayCast2D rayCastN2;

    private Nav2D nav2D;

    private Vector2 visionConeDirection =  Vector2.Right;
    private float fullRotationCheck = 0;

    private bool updatedPlayerGhost = false;
    private int raycastInversion = 1;
    
    private string roamState = "RoamToRandomCell";

    public enum States {
        Idle,
        Roam,
        Search,
        Chase
    }

    public override void _Ready() {
        base._Ready();
        detectionTimer = GetNode<Timer>("DetectionTimer");
        stateDurationTimer = GetNode<Timer>("StateDurationTimer");
        reactionTimer = GetNode<Timer>("ReactionTimer");
        roamDelayTimer = GetNode<Timer>("RoamDelayTimer");
        rayCastN1 = GetNode<RayCast2D>("VisionConeArea/RayCast2DN1");
        rayCastN2 = GetNode<RayCast2D>("VisionConeArea/RayCast2DN2");

        detectionTimer.Connect("timeout", this, nameof(OnDetectionTimerTimeout));
        stateDurationTimer.Connect("timeout", this, nameof(OnStateDurationTimerTimeout));
        reactionTimer.Connect("timeout", this, nameof(OnReactionTimerTimeout));
        roamDelayTimer.Connect("timeout", this, nameof(OnRoamDelayTimerTimeout));

        SpawnPosition = GlobalPosition;

        state = ChooseRandomState(new Array<States> { States.Idle, States.Roam });
    }

    public override void _Process(float delta) {
        base._Process(delta);
        AimRaycasts();
    }

    public override void _PhysicsProcess(float delta) {
        visionConeDirection = new Vector2((float) Math.Cos(visionConeArea.Rotation), (float) Math.Sin(visionConeArea.Rotation));

        switch (state) {
            case States.Idle:
                if (rayCastN1.IsColliding()) {
                    raycastInversion = -1;
                }
                else if (rayCastN2.IsColliding()) {
                    raycastInversion = 1;
                }

                if (canSeeTarget) {
                    Detect();
                }

                visionConeArea.Rotation += (float) 0.01 * raycastInversion;
                velocity = velocity.MoveToward(Vector2.Zero, Friction * delta);
                break;
            
            case States.Roam:
                if (randomRoamCell == null) {
                    GetRandomRoamCell();
                }

                switch (roamState) {
                    case "RoamToRandomCell":
                        SetTarget(randomRoamCell);
                        MoveAlongPath(delta);
                        break;
                        
                    case "RoamToSpawnCell":
                        SetTarget(SpawnPosition);
                        MoveAlongPath(delta);
                        break;
                }
                
                if (reachedEndOfPath) {
                    roamDelayTimer.Start();
                    state = States.Idle;
                }

                if (canSeeTarget) {
                    Detect();
                    velocity = velocity.MoveToward(Vector2.Zero, Friction * delta);
                }
                else {
                    AngleVisionCone(velocity.Normalized(), (float) 0.05);
                }

                break;
            
            case States.Search:
                stateDurationTimer.Stop();
                
                SetTarget(lastknownPlayerposition);
                SetLastknownPlayerposition(lastknownPlayerposition);
                MoveAlongPath(delta);

                if (reachedEndOfPath) {
                    if (fullRotationCheck < 2 * Math.PI) {
                        visionConeArea.Rotation += (float) 0.015;
                        fullRotationCheck += (float) 0.015;
                    }
                    else if (fullRotationCheck >= 2 * Math.PI) {
                        state = ChooseRandomState(new Array<States> {States.Idle, States.Roam});
                        fullRotationCheck = 0;
                    }
                }
                else {
                    AngleVisionCone((lastknownPlayerposition - GlobalPosition).Normalized(), (float) 0.1);
                }

                if (canSeeTarget) {
                    state = States.Chase;
                }

                break;
            
            case States.Chase:
                stateDurationTimer.Stop();
                
                if (canSeeTarget) {
                    ChaseTarget(delta);
                    AngleVisionCone(velocity.Normalized(), (float) 0.6);
                }
                else if (!canSeeTarget) {
                    velocity = velocity.MoveToward(Vector2.Zero, Friction * delta);
                    if (reactionTimer.IsStopped()) {
                        reactionTimer.Start();
                    }
                }

                break;
        }
    }

    private void AngleVisionCone(Vector2 target, float weight) {
        if (target != Vector2.Zero) {
            visionConeDirection = visionConeDirection.Slerp(target, weight); // Where factor is 0.0 - 1.0
            visionConeArea.Rotation = visionConeDirection.Angle();
        }
    }
    
    private void Detect() {
        if (target != null) {
            if (canSeeTarget) {
                AngleVisionCone((target.GlobalPosition - GlobalPosition).Normalized(), (float) 0.3);
                if (detectionTimer.IsStopped()) {
                    detectionTimer.Start();
                }
            }
            else if (!canSeeTarget) {
                detectionTimer.Stop();
            }
        }
    }

    private void GetRandomRoamCell() {
        Villager villager = this;
        Events.EmitEvent(nameof(Events.RequestRoamCell), villager);
    }
    
    private void OnDetectionTimerTimeout() {
        if (canSeeTarget) {
            state = States.Chase;
        }
    }
    
    private void OnReactionTimerTimeout() {
        state = States.Search;
    }
    
    private void OnRoamDelayTimerTimeout() {
        if (roamState == "RoamToRandomCell") {
            roamState = "RoamToSpawnCell";
        }
        else if (roamState == "RoamToSpawnCell") {
            roamState = "RoamToRandomCell";
        }

        state = States.Roam;
    }

    private void OnStateDurationTimerTimeout() {
        if (canSeeTarget) {
            state = States.Chase;
        }

        else if (state == States.Idle || state == States.Roam && reachedEndOfPath) {
            state = ChooseRandomState(new Array<States> {States.Idle, States.Roam});
            stateDurationTimer.WaitTime = (float) GD.RandRange(8, 30);
            stateDurationTimer.Start();
        }
    }

    private States ChooseRandomState(Array<States> statesList) {
        statesList.Shuffle();
        States firstState = statesList[0];
        statesList.Remove(firstState);
        return firstState;
    }
}
