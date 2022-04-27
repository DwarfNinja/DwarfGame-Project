using Godot;
using System;

[Tool]
public class CraftingButton : Button {

    [Export]
    public R_Craftable CraftableDef {
        get => craftableDef;
        set {
            craftableDef = value;
            Icon = value.BlueprintIcon;
        }
    }

    private R_Craftable craftableDef;

    private TextureRect selector;
    private AnimationPlayer animationPlayer;

    public override void _Ready() {
        selector = GetNode<TextureRect>("Selector");
        animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
        
        Icon = craftableDef.BlueprintIcon;
        Connect("pressed", this, nameof(OnButtonPressed));
        Connect("mouse_entered", this, nameof(OnMouseEntered));
    }

    public void CraftItem() {
        Events.EmitEvent("craft_item", craftableDef);
    }

    public void ActivateCraftingSelector() {
        selector.Show();
        animationPlayer.Play("Crafting Selector Selecting");
    }
    
    public void DeactivateCraftingSelector() {
        animationPlayer.Play("Crafting Selector Idle");
        selector.Hide();
    }

    private void OnButtonPressed() {
        CraftItem();
    }
    
    private void OnMouseEntered() {
        Events.EmitEvent(nameof(Events.CraftingButtonMouseEntered), this);
    }
}
