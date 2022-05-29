using Godot;
using System;

public class ForgeUI : PopupDialog {

    private R_Item iron;
    private HSlider ironAmountHSlider;
    private Label ironAmountLabel;

    private bool forgeOpened;
    private Forge currentOpenedForge;
    private int sliderIronAmount = 1;

    private Player interactingPlayer;

    public override void _Ready() {
        iron = GD.Load<R_Item>("res://Resources/Entities/Resources/Iron.tres");
        ironAmountHSlider = GetNode<HSlider>("IronAmountHSlider");
        ironAmountLabel = GetNode<Label>("IronAmountLabel");
        
        ironAmountHSlider.Connect("value_changed", this, nameof(OnHSliderValueChanged));
        
        Connect("popup_hide", this, nameof(OnPopUpHide));
    }
    
    public override void _GuiInput(InputEvent @event) {
        if (currentOpenedForge != null) {
            if (@event.IsActionPressed("key_e")) {
                InsertIron();
            }
        }
    }
    
    public void OpenForgeUI(Forge forge, Player interactingPlayer) {
        PopupCentered();
        currentOpenedForge = forge;
        this.interactingPlayer = interactingPlayer;
        ironAmountHSlider.Editable = true;
    }

    private void InsertIron() {
        if (currentOpenedForge.CanStartForge()) {
            if (interactingPlayer.Inventory.RemoveItemFromInventory(iron, sliderIronAmount)) {
                currentOpenedForge.StartForge(sliderIronAmount);
                ironAmountHSlider.Editable = false;
            }
            else {
                GD.Print("Not enough resources!");
            }
        }
    }

    private void OnHSliderValueChanged(float value) {
        sliderIronAmount = (int) value;
        ironAmountLabel.Text = sliderIronAmount.ToString();
    }

    private void OnPopUpHide() {
        currentOpenedForge = null;
        interactingPlayer = null;
    }
}
