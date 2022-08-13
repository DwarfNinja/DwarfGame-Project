using Godot;
using System;
using System.Linq;

public class InventoryBar : MarginContainer {

    private HBoxContainer hBoxContainer;

    private TextureRect selectedSlot;

    public override void _Ready() {
        hBoxContainer = (HBoxContainer) GetNode("SlotContainer/HBoxContainer");
        
        Events.ConnectEvent(nameof(Events.UpdateSlot), this, nameof(OnUpdateSlot));
        Events.ConnectEvent(nameof(Events.UpdateSelector), this, nameof(OnUpdateSelector));

        selectedSlot = hBoxContainer.GetNode<TextureRect>("Slot_0");
    }

    private void OnUpdateSlot(Slot slot) {
        TextureRect inventoryBarSlot = (TextureRect) GetNode("SlotContainer/HBoxContainer/" + slot.SlotName);
        Label itemCountLabel = (Label) inventoryBarSlot.GetNode("ItemCount");
        R_Item itemDef = slot.ItemDef;
        int amount = slot.Amount;
        
        if (itemDef == null) {
            inventoryBarSlot.Texture = null;
            itemCountLabel.Text = "";
            return;
        }
        inventoryBarSlot.Texture = itemDef.HudTexture;
        itemCountLabel.Text = amount.ToString();
        
        if (itemCountLabel.Text == "0") {
            inventoryBarSlot.Texture = null;
            itemCountLabel.Text = "";
        }
    }

    private void OnUpdateSelector(Slot slot, bool selecting) {
        TextureRect slotSelector = selectedSlot.GetNode<TextureRect>("Selector");
        slotSelector.Hide();
        
        selectedSlot = hBoxContainer.GetNode<TextureRect>(slot.SlotName);
        slotSelector = selectedSlot.GetNode<TextureRect>("Selector");
        
        AnimationPlayer slotSelectorAnimationPlayer = (AnimationPlayer) selectedSlot.GetNode("AnimationPlayer");
        
        slotSelector.Show();
        slotSelectorAnimationPlayer.Play(selecting ? "Selector Selecting" : "Selector Idle");
    }
}

