using Godot;
using System;

public class ForgeHUD : TextureRect {

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
    }

    public override void _Process(float delta) {
        if (currentOpenedForge != null) {
            if (Input.IsActionJustPressed("key_e")) {
                InsertIron();
            }

            if (Input.IsActionJustPressed("key_esc")) {
                CloseForgeUI();
            }
        }
    }

    private void InsertIron() {
        if (interactingPlayer.Inventory.RemoveItemFromInventory(iron, sliderIronAmount)) {
            currentOpenedForge.SetIronAmount(sliderIronAmount);
            ironAmountHSlider.Editable = false;
        }
        else {
            GD.Print("Not enough resources!");
        }
    }

    private void OnHSliderValueChanged(float value) {
        sliderIronAmount = (int) value;
        ironAmountLabel.Text = sliderIronAmount.ToString();
    }
    
    public void OpenForgeUI(Forge forge, Player interactingPlayer) {
        Show();
        currentOpenedForge = forge;
        this.interactingPlayer = interactingPlayer;
        ironAmountHSlider.Editable = true;
    }
    
    public void CloseForgeUI() {
        Hide();
        currentOpenedForge = null;
        interactingPlayer = null;
    }
}
