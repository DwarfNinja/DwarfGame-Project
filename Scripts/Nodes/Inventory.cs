using Godot;
using System;
using Godot.Collections;

public class Inventory : Node2D {

	private R_Item goldcoins = (R_Item) GD.Load("res://Resources/Entities/Resources/GoldCoins.tres");

	private Array<Slot> inventorySlots = new Array<Slot>() {
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
	private Slot selectedSlot;

	public R_Item SelectedItem {
		get => selectedItem;
	}

	public override void _Ready() {
		Events.ConnectEvent(nameof(Events.CraftItem), this, nameof(OnCraftItem));
		Events.ConnectEvent(nameof(Events.RemoveSelectedItem), this, nameof(OnRemoveSelectedItem));
		Events.EmitEvent(nameof(Events.UpdateSlotSelectors), selectorPosition, selectedSlot);
		
		playerItems = new Dictionary<R_Item, int>() {
			[goldcoins] =  0,
		};
	}

	public override void _Process(float delta) {
		Slot currentSlot = inventorySlots[selectorPosition];

		if (HUD.MenuOpen == false) {
			if (GetTree().CurrentScene?.Name == "Cave") {
				if (Input.IsActionJustPressed("key_leftclick")) {
					if (GetItemInSlot(currentSlot) != null) {
						if (GetItemInSlot(currentSlot).EntityType == R_Item.Type.Craftable) {
							SelectSlot(currentSlot);
						}
					}
				}

				if (Input.IsActionPressed("key_rightclick")) {
					if (selectedItem != null) {
						if (selectedItem.EntityType == R_Item.Type.Craftable) {
							Events.EmitEvent(nameof(Events.PlaceObject), selectedItem);
							SelectSlot(currentSlot);
						}
					}
				}
			}

			//Determines Selector position based on scroll wheel movement
			if (Input.IsActionJustReleased("scroll_up")) {
				selectorPosition += 1;
				if (selectorPosition > 5) {
					selectorPosition = 0;
				}
				DeselectSlot();
			}

			else if (Input.IsActionJustReleased("scroll_down")) {
				selectorPosition -= 1;
				if (selectorPosition < 0) {
					selectorPosition = 5;
				}
				DeselectSlot();
			}

			if (Input.IsActionJustPressed("key_q")) {
				if (GetItemInSlot(currentSlot) != null) {
					Events.EmitEvent(nameof(Events.DropSelectedItem), GetItemInSlot(currentSlot));
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

	private void SelectSlot(Slot currentSlot) {
		selectedSlot = currentSlot;
		selectedItem = GetItemInSlot(currentSlot);
		Events.EmitEvent(nameof(Events.UpdateSlotSelectors), currentSlot);
	}

	private void DeselectSlot() {
		selectedSlot = null;
		selectedItem = null;
		Events.EmitEvent(nameof(Events.UpdateSlotSelectors), selectorPosition, selectedSlot);
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

			while (!slot.IsEmpty() && amount > 0) {
				amount -= 1;
			}
		}

		return amount > 0;
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
		selectedSlot.RemoveItem(itemDef);
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
