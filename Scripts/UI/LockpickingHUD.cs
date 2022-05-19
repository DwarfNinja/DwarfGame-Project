using Godot;
using System;
using Godot.Collections;

public class LockpickingHUD : TextureRect {

    private Control lockpickRotAnchor;
    private Control lockpickPosAnchor;
    private Control lockCylinder;
    
    private AnimationPlayer animationPlayer;
    
    private double currentAngle = 0;
    private int randomUnlockAngle = 90;
    
    private bool lockPickBroken = false;
    private int closestDistance;
    private int possibleTurnRadius;
    private int difficultyModifier = 5;
    private int lockPickHealth = 50;
    
    private Dictionary<string, int> difficultyDictionary = new Dictionary<string, int> {
        ["EASY"] = 10,
        ["MEDIUM"] = 5,
        ["HARD"] = 2
    };
    
    public override void _Ready() {
        lockpickRotAnchor = GetNode<Control>("LockpickRotAnchor");
        lockpickPosAnchor = GetNode<Control>("LockCylinder/LockpickPosAnchor");
        lockCylinder = GetNode<Control>("LockCylinder");
        animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");

        randomUnlockAngle = GetRandomUnlockAngle(); 
        closestDistance = CalculateClosestHalf(); 
        possibleTurnRadius = CalculatePossibleTurnRadius();
    }

    public override void _PhysicsProcess(float delta) {
        if (CanReceiveInput()) {
            lockpickRotAnchor.RectGlobalPosition = lockpickPosAnchor.RectGlobalPosition;
            RotateLockpick();
            closestDistance = CalculateClosestHalf();
            possibleTurnRadius = CalculatePossibleTurnRadius();

            if (Input.IsActionPressed("key_up")) {
                TurnCylinder();
            }
            else if (lockCylinder.RectRotation > 0) {
                lockCylinder.RectRotation -= 1;
            }
        }
        
        if (Input.IsActionPressed("key_f")) {
            lockPickHealth = 50;
            lockPickBroken = false;
            animationPlayer.Play("RESET");
        }
    }

    private void RotateLockpick() {
        if (lockpickRotAnchor.RectGlobalPosition.DistanceTo(GetGlobalMousePosition()) > 2) {
            Vector2 angleToMouse = lockpickRotAnchor.RectGlobalPosition - GetGlobalMousePosition();
            lockpickRotAnchor.SetRotation(Mathf.LerpAngle(lockpickRotAnchor.GetRotation(), angleToMouse.Angle(), (float) 0.2));

            currentAngle = Math.Round(Mathf.Rad2Deg(angleToMouse.Angle()));
            currentAngle = currentAngle < 0 ? currentAngle + 360 : currentAngle;
        }
    }
    
    private void TurnCylinder() {
        if (lockCylinder.RectRotation < Math.Min(possibleTurnRadius + difficultyModifier, 90)) {
            lockCylinder.RectRotation += 2;
        }
        else {
            DamageLockpick();
        }
    }

    private int GetRandomUnlockAngle() {
        return (int) Math.Round(GD.RandRange(-180, 180));
    }

    private int CalculateClosestHalf() {
        double firstHalf = Math.Abs(currentAngle - randomUnlockAngle);
        double secondHalf = Math.Abs(randomUnlockAngle + (360 - currentAngle));
        return (int) Math.Min(firstHalf, secondHalf);
    }

    private int CalculatePossibleTurnRadius() {
        double anglePercentage = (double) closestDistance / 180 * 100;
        double flippedAnglePercentage = 100 - anglePercentage;
        return (int) Math.Round(90 * (flippedAnglePercentage / 100));
    }

    private bool LockIsUnlocked() {
        return lockCylinder.RectRotation >= 90;
    }

    private bool CanReceiveInput() {
        return !lockPickBroken && !LockIsUnlocked();
    }

    private void DamageLockpick() {
        animationPlayer.Play("Damage Lockpick");
        lockPickHealth -= 1;
        if (!lockPickBroken && lockPickHealth <= 0) {
            BreakLockpick();
        }
    }

    private void BreakLockpick() {
        animationPlayer.Play("Break Lockpick");
        lockPickBroken = true;
    }
}
