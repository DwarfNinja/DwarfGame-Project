using Godot;
using System;
using System.Linq;

public class CraftingTableUI : PopupDialog {
    
    private GridContainer gridContainer;
    
    private CraftingButton selectedButton;

    private int craftingSelectorPosition;

    public override void _Ready() {
        gridContainer = GetNode<GridContainer>("GridContainer");
        selectedButton = GetNode<CraftingButton>("GridContainer/CraftingButton_" + craftingSelectorPosition);
        
        Events.ConnectEvent(nameof(Events.CraftingButtonMouseEntered), this, nameof(OnCraftingButtonMouseEntered));
    }

    public override void _GuiInput(InputEvent @event) {
        int horAdd = 1;
        int vertAdd = 3;
        
        if (@event.IsActionPressed("key_e")) {
            selectedButton.CraftItem();
        }
        
        if (@event.IsActionPressed("key_right") || @event.IsActionPressed("scroll_up")) {
            craftingSelectorPosition += horAdd;
            if (craftingSelectorPosition > 5) {
                craftingSelectorPosition = 0;
            }
        }
        
        if (@event.IsActionPressed("key_left") || @event.IsActionPressed("scroll_down")) {
            craftingSelectorPosition -= horAdd;
            if (craftingSelectorPosition < 0) {
                craftingSelectorPosition = 5;
            }
        }
        
        if (@event.IsActionPressed("key_down")) {
            craftingSelectorPosition += craftingSelectorPosition < 3 || craftingSelectorPosition == 5 ? vertAdd : -2;
            if (craftingSelectorPosition > 5) {
                craftingSelectorPosition = 0;
            }
        }
        
        if (@event.IsActionPressed("key_up")) {
            craftingSelectorPosition -= craftingSelectorPosition >= 3 || craftingSelectorPosition == 0 ? vertAdd : -2;
            if (craftingSelectorPosition < 0) {
                craftingSelectorPosition = 5;
            }
        }

        UpdateSelectedButton();
        UpdateResourceBar();
    }

    public void OpenCraftingTableUI() {
        PopupCentered();
    }

    private void UpdateSelectedButton() {
        selectedButton.DeactivateCraftingSelector();
        selectedButton = GetNode<CraftingButton>("GridContainer/CraftingButton_" + craftingSelectorPosition);
        selectedButton.ActivateCraftingSelector();
    }

    private void UpdateResourceBar() {
        R_Craftable itemDefInCraftingButton = selectedButton.CraftableDef;
        GetNode<Label>("WoodCostLabel").Text = itemDefInCraftingButton.RequiredItems.Values.ToArray()[0].ToString();
        GetNode<Label>("IronCostLabel").Text = itemDefInCraftingButton.RequiredItems.Values.ToArray()[1].ToString();
    }

    private void OnCraftingButtonMouseEntered(CraftingButton button) {
        craftingSelectorPosition = button.Name.Split("CraftingButton_")[1].ToInt();
        UpdateSelectedButton();
        UpdateResourceBar();
    }
}
