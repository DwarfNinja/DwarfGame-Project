using Godot;
using System;
using System.Linq;
using Godot.Collections;

public class InventoryBar : MarginContainer {

    private HBoxContainer hBoxContainer;

    public override void _Ready() {
        hBoxContainer = (HBoxContainer) GetNode("SlotContainer/HBoxContainer");
        
        Events.ConnectEvent(nameof(Events.UpdateSlot), this, nameof(OnUpdateSlot));
        Events.ConnectEvent(nameof(Events.UpdateSlotSelectors), this, nameof(OnUpdateSlotSelectors));
    }

    public void OnUpdateSlotSelectors(int selectorPosition, string selectedSlot) {
    //Iterates over all the slots and determines if it is the slot selected,
    //all other slot's selectors are turned off
    
        foreach (int index in Enumerable.Range(0, hBoxContainer.GetChildCount())) {
            TextureRect slot = (TextureRect) hBoxContainer.GetChildren()[index];
            if (index == selectorPosition) {
                ActivateSelector(slot, selectedSlot);
            }
            else {
                DeactivateSelector(slot);
            }
        } 
    }

    private void OnUpdateSlot(string slot, R_Item itemDef, int count) {
        TextureRect inventoryBarSlot = (TextureRect) GetNode("SlotContainer/HBoxContainer/" + slot);
        if (itemDef != null) {
            inventoryBarSlot.Texture = itemDef.HudTexture;
            Label itemCountLabel = (Label) inventoryBarSlot.GetNode("ItemCount");
            itemCountLabel.Text = count.ToString();
            if (itemCountLabel.Text == "0") {
                inventoryBarSlot.Texture = null;
                itemCountLabel.Text = "";
            }
            else {
                inventoryBarSlot.Texture = null;
                itemCountLabel.Text = "";
            }
        }
    }
    
    private void ActivateSelector(TextureRect slot, string selectedSlot) {
        TextureRect slotSelector = (TextureRect) slot.GetNode("Selector");
        slotSelector.Show();
        AnimationPlayer slotSelectorAnimationPlayer = (AnimationPlayer) slotSelector.GetNode("AnimationPlayer");
        if (slot.Name == selectedSlot) {
            slotSelectorAnimationPlayer.Play("Selector Selecting");
        }
        else {
            slotSelectorAnimationPlayer.Play("Selector Idle");
        }
    }

    private void DeactivateSelector(TextureRect slot) {
        TextureRect slotSelector = (TextureRect) slot.GetNode("Selector");
        slotSelector.Hide();
        AnimationPlayer slotSelectorAnimationPlayer = (AnimationPlayer) slotSelector.GetNode("AnimationPlayer");
        slotSelectorAnimationPlayer.Play("Selector Idle");
    }
}

