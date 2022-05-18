using Godot;
using System;
using Godot.Collections;

public class LockpickingHUD : TextureRect {

    private Control lockpickRotAnchor;
    private Control lockpickPosAnchor;
    private Control lockCylinder;
    
    private AnimationPlayer animationPlayer;
    
    private double currentAngle = 0;
    private double randomUnlockAngle;
    
    private bool lockPickBroken = false;
    private double closestDistance;
    private double possibleTurnRadius;
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
        GD.Print(lockCylinder.RectRotation);
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
            currentAngle = currentAngle < 0 ? currentAngle : currentAngle + 360;
        }
    }
    
    private void TurnCylinder() {
        if (lockCylinder.RectRotation < Math.Min(possibleTurnRadius + difficultyModifier, 88)) {
            lockCylinder.RectRotation += 2;
        }
        else {
            DamageLockpick();
        }
    }

    private double GetRandomUnlockAngle() {
        return Math.Round(GD.RandRange(-180, 180));
    }

    private double CalculateClosestHalf() {
        double firstHalf = Math.Abs(currentAngle - randomUnlockAngle);
        double secondHalf = Math.Abs(randomUnlockAngle + (360 - currentAngle));
        return Math.Min(firstHalf, secondHalf);
    }

    private double CalculatePossibleTurnRadius() {
        double anglePercentage = (closestDistance / 180) * 100;
        double flippedAnglePercentage = 100 - anglePercentage;
        return Math.Round(90 * (flippedAnglePercentage / 100));
    }

    private bool LockIsUnlocked() {
        return Math.Round(lockCylinder.RectRotation) >= 90;
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
