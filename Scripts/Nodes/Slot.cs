using Godot;

namespace DwarfGameProject.Scripts.Nodes {
    public class Slot : Node2D {
        private string slotName;
        private RW_Item itemDef;
        private int amount;

        public Slot(string slotName, RW_Item itemDef, int amount) {
            this.slotName = slotName;
            this.itemDef = itemDef;
            this.amount = amount;
        }

        public string SlotName => slotName;

        public RW_Item ItemDef {
            get => itemDef;
            set => itemDef = value;
        }

        public int Amount {
            get => amount;
            set => amount = value;
        }

        public void AddItem(RW_Item itemDef) {
            this.itemDef = itemDef;
            amount += 1;
            Events.EmitEvent(nameof(Events.UpdateSlot), this);
        }
        
        public void RemoveItem(RW_Item itemDef) {
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
        
        public bool HasItem(RW_Item itemDef) {
            return this.itemDef.Equals(itemDef);
        }
        
        public bool HasAmount(int amount) {
            return this.amount == amount;
        }
	
        public bool IsFull() {
            return amount >= 4;
        }
	
        public bool IsEmpty() {
            return amount <= 0;
        }
    }
}