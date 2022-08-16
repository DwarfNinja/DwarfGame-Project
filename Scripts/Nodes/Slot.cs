using Godot;
using System;

public class Slot : Node2D {
    private string slotName;
    private R_Item itemDef;
    private int amount;

    public Slot(string slotName, R_Item itemDef, int amount) {
        this.slotName = slotName;
        this.itemDef = itemDef;
        this.amount = amount;
    }

    public string SlotName => slotName;

    public R_Item ItemDef {
        get => itemDef;
        set => itemDef = value;
    }

    public int Amount {
        get => amount;
        set => amount = value;
    }

    public void AddItem(R_Item itemDef) {
        this.itemDef = itemDef;
        amount += 1;
        Events.EmitEvent(nameof(Events.UpdateSlot), this);
    }
    
    public void RemoveItem(R_Item itemDef) {
        if (this.itemDef.Equals(itemDef)) {
            if (!IsEmpty()) {
                amount -= 1;
                if (IsEmpty()) {
                    this.itemDef = null;
                }
            }
            Events.EmitEvent(nameof(Events.UpdateSlot), this);
        }
    }
    
    public bool HasItem(R_Item itemDef) {
        return this.itemDef != null && this.itemDef.Equals(itemDef);
    }
    
    public bool HasAmount(int amount) {
        return this.amount == amount;
    }

    public bool IsFull() {
        return amount >= 4;
    }

    public bool IsEmpty() {
        return amount == 0;
    }
}
