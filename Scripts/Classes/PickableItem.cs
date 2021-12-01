using Godot;
using System;

public class PickableItem : RigidBody2D {
    [Export] 
    public R_Item itemDef;

    private Sprite itemSprite;
    private Particles2D trailParticles2D;
    // private AnimationPlayer animationPlayer;
    private CollisionShape2D collisionShape2D;
    private Tween tween;
    
    private Vector2 direction = Vector2.Zero;
    private Node2D target = null;
    private Vector2 targetPos;
    
    public override void _Ready() {
        // animationPlayer.Connect("animation_finished", this, nameof(OnAnimationPlayerAnimationFinished));
        itemSprite = (Sprite) GetNode("ItemSprite");
        tween = (Tween) GetNode("Tween");
        collisionShape2D = (CollisionShape2D) GetNode("CollisionShape2D");
        
        tween.Connect("tween_all_completed", this, nameof(OnTweenTweenAllCompleted));
        Events.ConnectEvent(nameof(Events.EnteredPickupArea), this, nameof(OnEnteredPickupArea));
        Events.ConnectEvent(nameof(Events.ExitedPickupArea), this, nameof(OnExitedPickupArea));

        if (itemDef == null) {
            itemSprite.Texture = null;
            throw new Exception("ERROR: No item_def defined in item " + this);
        }
        SetItem(itemDef);
    }

    public override void _IntegrateForces(Physics2DDirectBodyState state) {
        if (target != null) {
            if (target is Player player) {
                if (player.Inventory.CanFitInInventory(itemDef)) {
                    MoveToTarget(state);
                    
                    if (GlobalPosition.DistanceTo(player.GlobalPosition) < 15) {
                        Events.EmitEvent(nameof(Events.ItemPickedUp), itemDef);
                        QueueFree();
                    }
                }
            }
        }
    }

    private void MoveToTarget(Physics2DDirectBodyState state) {
        direction = (GlobalPosition - target.GlobalPosition).Normalized();
        ApplyCentralImpulse(-direction * 5);
    }

    private void SetItem(R_Item itemDef) {
        this.itemDef = itemDef;
        itemSprite.Texture = this.itemDef.ItemTexture;
    }

    private void play_chestdrop_animation(Vector2 dropDirection) {
        collisionShape2D.Disabled = true;
        targetPos = GlobalPosition + dropDirection;
        const int itemJumpHeight = 32;

        tween.InterpolateProperty(this, "global_position:x", GlobalPosition.x, targetPos.x, (float) 0.5);
        tween.InterpolateProperty(this, "global_position:y", GlobalPosition.y, targetPos.y - itemJumpHeight, (float) 0.25);
        tween.InterpolateProperty(this, "global_position:y", targetPos.y - itemJumpHeight, targetPos.y, 
            (float) 0.85, Tween.TransitionType.Bounce, Tween.EaseType.Out, (float) 0.6);
        tween.Start();
    }

    private void OnEnteredPickupArea(Node2D body) {
        target = body;
    }
    
    private void OnExitedPickupArea(Node2D body) {
        target = null;
    }

    private void OnTweenTweenAllCompleted() {
        collisionShape2D.Disabled = false;
    }
}
