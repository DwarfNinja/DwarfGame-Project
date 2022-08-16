using Godot;
using System;
using Godot.Collections;

public class Inventory : Node2D {

	private R_Item goldcoins = (R_Item) GD.Load("res://Resources/Entities/Resources/GoldCoins.tres");

	private Array<Slot> inventorySlots = new Array<Slot> {
		new Slot("Slot_0", null, 0),
		new Slot("Slot_1", null, 0),
		new Slot("Slot_2", null, 0),
		new Slot("Slot_3", null, 0),
		new Slot("Slot_4", null, 0),
		new Slot("Slot_5", null, 0),
	};

	private Dictionary<R_Item, int> playerItems;

	private int selectorPosition = 0;
	private R_Item selectedItem;
	private Slot currentSlot;

	public R_Item SelectedItem {
		get => selectedItem;
	}

	public override void _Ready() {
		currentSlot = inventorySlots[0];
		playerItems = new Dictionary<R_Item, int> {
			[goldcoins] =  0,
		};
		
		Events.ConnectEvent(nameof(Events.CraftItem), this, nameof(OnCraftItem));
		Events.ConnectEvent(nameof(Events.RemoveSelectedItem), this, nameof(OnRemoveSelectedItem));
		Events.EmitEvent(nameof(Events.UpdateSelector), currentSlot, false);


	}

	public override void _UnhandledInput(InputEvent @event) {
		if (HUD.MenuOpen == false) {
			if (GetTree().CurrentScene?.Name == "Cave") {
				if (@event.IsActionPressed("key_leftclick")) {
					if (!currentSlot.IsEmpty()) {
						if (GetItemInSlot(currentSlot).EntityType == R_Item.Type.Craftable) {
							SelectSlot();
						}
					}
				}
				
				if (@event.IsActionPressed("key_rightclick")) {
					if (selectedItem != null) {
						if (selectedItem.EntityType == R_Item.Type.Craftable) {
							Events.EmitEvent(nameof(Events.PlaceObject), selectedItem);
							if (currentSlot.IsEmpty()) {
								DeselectSlot();
							}
						}
					}
				}
				
				if (@event.IsActionPressed("scroll_up")) {
					selectorPosition = selectorPosition < 5 ? selectorPosition += 1 : 0;
					currentSlot = inventorySlots[selectorPosition];
					Events.EmitEvent(nameof(Events.UpdateSelector), currentSlot, false);
				}

				else if (@event.IsActionPressed("scroll_down")) {
					selectorPosition = selectorPosition > 0 ? selectorPosition -= 1 : 5;
					currentSlot = inventorySlots[selectorPosition];
					Events.EmitEvent(nameof(Events.UpdateSelector), currentSlot, false);
				}

				if (@event.IsActionPressed("key_q")) {
					if (!currentSlot.IsEmpty()) {
						Events.EmitEvent(nameof(Events.DropSelectedItem), GetItemInSlot(currentSlot));
					}
				}
			}
		}
	}

	public bool PickUpItem(R_Item itemDef) {
		if (CanFitInInventory(itemDef)) {
			AddItem(itemDef);
			return true;
		}
		GD.Print("Inventory full, can't pick up item! " + itemDef.EntityName);
		return false;
	}
	
	public bool RemoveItemFromInventory(R_Item itemDef, int amount = 1) {
		if (HasItemInInventory(itemDef, amount)) {
			RemoveItem(itemDef, amount);
			return true;
		}
		GD.Print("Item not in Inventory, can't remove item! " + itemDef.EntityName);
		return false;
	}
	
	public bool CanFitInInventory(R_Item itemDef) {
		if (playerItems.ContainsKey(itemDef)) {
			return true;
		}
		foreach (Slot slot in inventorySlots){
			if (slot.IsEmpty()) {
				return true;
			}
			if (!slot.IsFull() && slot.HasItem(itemDef)) {
				return true;
			}
		}
		return false;
	}

	private void SelectSlot() {
		selectedItem = GetItemInSlot(currentSlot);
		Events.EmitEvent(nameof(Events.UpdateSelector), currentSlot, true);
	}
	
	private void DeselectSlot() {
		selectedItem = null;
		Events.EmitEvent(nameof(Events.UpdateSelector), currentSlot, false);
	}

	private R_Item GetItemInSlot(Slot slot) {
		return slot.ItemDef;
	}

	private void AddItem(R_Item itemDef, int amount = 1) {
		
		if (playerItems.ContainsKey(itemDef)) {
			AddToPlayerItems(itemDef);
			return;
		}
		foreach (Slot slot in inventorySlots) {
			for (int i = 0; i < amount; i++) {
				if (slot.IsEmpty()) {
					slot.AddItem(itemDef);
					return;
				}

				if (slot.HasItem(itemDef) && !slot.IsFull()) {
					slot.AddItem(itemDef);
					return;
				}
			}
		}
	}
	
	private void AddToPlayerItems(R_Item itemDef) {
		playerItems[itemDef] += 1;
		if (itemDef.Equals(goldcoins)) {
			Events.EmitEvent(nameof(Events.UpdateHudCoins), playerItems[goldcoins]);
		}
	}
	
	private void RemoveItem(R_Item itemDef, int amount = 1) {
		for (int i = inventorySlots.Count - 1; i >= 0; i--) {
			Slot slot = inventorySlots[i];
			if (!slot.HasItem(itemDef)) {
				continue;
			}

			while (!slot.IsEmpty() && amount > 0) {
				slot.RemoveItem(itemDef);
				amount -= 1;
			}
		}
	}

	private bool HasItemInInventory(R_Item itemDef, int amount = 1) {
		for (int i = inventorySlots.Count - 1; i >= 0; i--) {
			Slot slot = inventorySlots[i];
			if (!slot.HasItem(itemDef)) {
				continue;
			}

			int slotAmount = slot.Amount;
			while (slotAmount > 0 && amount > 0) {
				slotAmount -= 1;
				amount -= 1;
			}
		}
		return amount == 0;
	}

	private bool HasRequiredItemsToCraft(R_Craftable craftableDef) {
		Dictionary<R_Item, int> requiredItems = craftableDef.RequiredItems.Duplicate();

		foreach (R_Item requiredItem in requiredItems.Keys) {
			if (!HasItemInInventory(requiredItem, requiredItems[requiredItem])) {
				return false;
			}
		}
		return true;
	}
	
	private void OnRemoveSelectedItem(R_Item itemDef) {
		if (playerItems.ContainsKey(itemDef)) {
			playerItems[itemDef] -= 1;
			return;
		}
		currentSlot.RemoveItem(itemDef);
	}
	
	private void OnCraftItem(R_Craftable craftableDef) {
		if (HasRequiredItemsToCraft(craftableDef)) {
			Dictionary<R_Item, int> requiredItems = craftableDef.RequiredItems.Duplicate();
			foreach (R_Item requiredItem in requiredItems.Keys) {
				RemoveItem(requiredItem, requiredItems[requiredItem]);
			}
			AddItem(craftableDef);
		}
	}
}
