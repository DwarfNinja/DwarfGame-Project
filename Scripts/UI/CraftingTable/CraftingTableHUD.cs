using Godot;
using System;
using System.Linq;

public class CraftingTableHUD : TextureRect {
    
    private GridContainer gridContainer;
    
    private CraftingButton selectedButton;

    private int craftingSelectorPosition;
    private bool craftingTableOpened;
    
    public override void _Ready() {
        gridContainer = GetNode<GridContainer>("GridContainer");
        selectedButton = GetNode<CraftingButton>("GridContainer/CraftingButton_" + craftingSelectorPosition);
        
        Events.ConnectEvent(nameof(Events.OpenCraftingTable), this, nameof(OnOpenCraftingTable));
        Events.ConnectEvent(nameof(Events.CloseCraftingTable), this, nameof(OnCloseCraftingTable));
        Events.ConnectEvent(nameof(Events.CraftingButtonMouseEntered), this, nameof(OnCraftingButtonMouseEntered));
    }
    
    public override void _Process(float delta) {
        // Determines Selector position based on scroll wheel movement
        if (craftingTableOpened) {
            UpdateResourceBar();
            int horAdd = 2;
            int vertAdd = 1;
            
            if (Input.IsActionJustPressed("key_esc")) {
                Hide();
                craftingTableOpened = false;
                HUD.MenuOpen = false;
            }

            if (Input.IsActionJustPressed("ui_right") || Input.IsActionJustReleased("scroll_up")) {
                craftingSelectorPosition += horAdd;
                if (craftingSelectorPosition == 7) {
                    craftingSelectorPosition = 0;
                }
                else if (craftingSelectorPosition == 6) {
                    craftingSelectorPosition = 1;
                }
            }
            
            if (Input.IsActionJustPressed("ui_left")) {
                craftingSelectorPosition -= horAdd;
                if (craftingSelectorPosition == -1) {
                    craftingSelectorPosition = 4;
                }
                else if (craftingSelectorPosition == -2) {
                    craftingSelectorPosition = 5;
                }
            }
            
            if (Input.IsActionJustPressed("ui_down") || Input.IsActionJustReleased("scroll_down")) {
                craftingSelectorPosition += vertAdd;
                if (craftingSelectorPosition == 6) {
                    craftingSelectorPosition = 0;
                }
            }
            
            if (Input.IsActionJustPressed("ui_up")) {
                craftingSelectorPosition -= vertAdd;
                if (craftingSelectorPosition < 0) {
                    craftingSelectorPosition = 5;
                }
            }
        }

        selectedButton = GetNode<CraftingButton>("GridContainer/CraftingButton_" + craftingSelectorPosition);

        if (Input.IsActionJustPressed("key_e")) {
            if (craftingTableOpened) {
                selectedButton.CraftItem();
            }
        }
        
        // Iterates over all buttons and determines if it the button is selected,
        // all other button's selectors are turned off
        foreach (CraftingButton button in gridContainer.GetChildren()) {
            int buttonNumber = button.Name.Split("CraftingButton_")[1].ToInt();

            if (buttonNumber == craftingSelectorPosition) {
                button.ActivateCraftingSelector();
            }
            else {
                button.DeactivateCraftingSelector();
            }
        }
    }

    private void UpdateResourceBar() {
        R_Craftable itemDefInCraftingButton = selectedButton.CraftableDef;
        GetNode<Label>("ResouceBar/WoodCostLabel").Text = itemDefInCraftingButton.RequiredItems.Values.ToArray()[0].ToString();
        GetNode<Label>("ResouceBar/IronCostLabel").Text = itemDefInCraftingButton.RequiredItems.Values.ToArray()[1].ToString();
    }
    
    private void OnCraftingButtonMouseEntered(CraftingButton button) {
        craftingSelectorPosition = button.Name.Split("CraftingButton_")[1].ToInt();
    }

    private void OnOpenCraftingTable() {
        Show();
        craftingTableOpened = true;
        HUD.MenuOpen = true;
    }
    
    private void OnCloseCraftingTable() {
        Hide();
        craftingTableOpened = false;
        HUD.MenuOpen = false;
    }
}
