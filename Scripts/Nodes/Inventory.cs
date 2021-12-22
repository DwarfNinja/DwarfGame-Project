using Godot;
using System;
using System.Linq;
using DwarfGameProject.Scripts.Nodes;
using Godot.Collections;
using Array = Godot.Collections.Array;

public class Inventory : Node2D {

	private RW_Item goldcoins = RW_Item.LoadResource("res://Resources/Entities/Resources/GoldCoins.tres");

	private Array<Slot> inventorySlots = new Array<Slot>() {
		new Slot("Slot_0", null, 0),
		new Slot("Slot_1", null, 0),
		new Slot("Slot_2", null, 0),
		new Slot("Slot_3", null, 0),
		new Slot("Slot_4", null, 0),
		new Slot("Slot_5", null, 0),
	};

	private System.Collections.Generic.Dictionary<RW_Item, int> playerItems;

	private int selectorPosition = 0;
	private RW_Item selectedItem;
	private Slot selectedSlot;

	public override void _Ready() {
		Events.ConnectEvent(nameof(Events.CraftItem), this, nameof(OnCraftItem));
		Events.ConnectEvent(nameof(Events.RemoveSelectedItem), this, nameof(OnRemoveSelectedItem));
		Events.EmitEvent(nameof(Events.UpdateSlotSelectors), selectorPosition, selectedSlot);
		
		playerItems = new System.Collections.Generic.Dictionary<RW_Item, int>() {
			[goldcoins] =  0,
		};
	}

	public override void _Process(float delta) {
		Slot currentSlot = inventorySlots[selectorPosition];

		if (HUD.MenuOpen == false) {
			if (GetTree().CurrentScene.Name == "Cave") {
				if (Input.IsActionJustPressed("key_leftclick")) {
					if (GetItemInSlot(currentSlot) != null) {
						if (GetItemInSlot(currentSlot).EntityType == RW_Item.Type.Craftable) {
							SelectSlot(currentSlot);
						}
					}
				}

				if (Input.IsActionPressed("key_rightclick")) {
					if (selectedItem != null) {
						if (selectedItem.EntityType == RW_Item.Type.Craftable) {
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

	private RW_Item GetItemInSlot(Slot slot) {
		return slot.ItemDef;
	}

	public bool PickUpItem(RW_Item itemDef) {
		if (CanFitInInventory(itemDef)) {
			AddItem(new RW_Item(itemDef));
			return true;
		}
		else {
			GD.Print("Inventory full, can't pick up item!" + itemDef.EntityName);
			return false;
		}
	}

	private void AddItem(RW_Item itemDef, int amount = 1) {
		
		if (playerItems.ContainsKey(itemDef)) {
			AddToPlayerItems(itemDef);
			return;
		}
		foreach (Slot slot in inventorySlots) {
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
	
	private void AddToPlayerItems(RW_Item itemDef) {
		playerItems[itemDef] += 1;
		if (itemDef.Equals(goldcoins)) {
			Events.EmitEvent(nameof(Events.UpdateHudCoins), playerItems[goldcoins]);
		}
	}
	
	private void RemoveItem(RW_Item itemDef, int amount = 1) {
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

	public bool CanFitInInventory(RW_Item itemDef) {
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

	private bool HasItemInInventory(RW_Item itemDef, int amount = 1) {
		foreach (Slot slot in inventorySlots) {
			if (slot.HasItem(itemDef) && slot.HasAmount(amount)) {
				return true;
			}
		}
		return false;
	}

	private bool HasRequiredItemsToCraft(RW_Craftable craftableDef) {
		Dictionary<RW_Item, int> requiredItems = craftableDef.RequiredItems.Duplicate();

		foreach (RW_Item requiredItem in requiredItems.Keys) {
			if (!HasItemInInventory(requiredItem, requiredItems[requiredItem])) {
				return false;
			}
		}
		return true;
	}
	
	private void OnRemoveSelectedItem(RW_Item itemDef) {
		if (playerItems.ContainsKey(itemDef)) {
			playerItems[itemDef] -= 1;
			return;
		}
		selectedSlot.RemoveItem(itemDef);
	}
	
	private void OnCraftItem(RW_Craftable craftableDef) {
		if (HasRequiredItemsToCraft(craftableDef)) {
			Dictionary<RW_Item, int> requiredItems = craftableDef.RequiredItems.Duplicate();
			foreach (RW_Item requiredItem in requiredItems.Keys) {
				RemoveItem(requiredItem, requiredItems[requiredItem]);
			}
			AddItem(craftableDef);
		}
	}
	
	// //TODO: Algorithm can be improved
	// private void RemoveRequiredItems(R_Craftable craftableDef) {
	// 	Dictionary<R_Item, int> requiredItems = craftableDef.requiredItems.Duplicate();
	//
	// 	for (int i = inventorySlots.Count - 1; i >= 0; i--) {
	// 		Slot slot = inventorySlots[i];
	// 		if (slot.ItemDef == null) {
	// 			continue;
	// 		}
	// 		foreach (R_Item requiredItem in requiredItems.Keys) {
	// 			if (slot.HasItem(requiredItem)) {
	// 				foreach (int amount in Enumerable.Range(0, requiredItems[requiredItem])) {
	// 					if (!slot.IsEmpty()) {
	// 						slot.RemoveItem(requiredItem);
	// 						requiredItems[requiredItem] -= 1;
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// }
	//
	// //TODO: Algorithm could be improved
	// private bool HasRequiredItemsInInventory(R_Craftable craftableDef) {
	// 	Dictionary<R_Item, int> requiredItems = craftableDef.requiredItems.Duplicate();
	// 	
	// 	foreach (R_Item requiredItem in requiredItems.Keys) {
	// 		foreach (Slot slot in inventorySlots) {
	// 			if (slot.HasItem(requiredItem)) {
	// 				requiredItems[requiredItem] -= slot.Count;
	// 			}
	// 		}
	// 		if (requiredItems[requiredItem] > 0) {
	// 			return false;
	// 		}
	// 	}
	// 	return true;
	// }
	//
	// //TODO: Could be merged with RemoveRequiredItems and/or HasRequiredItemsInInventory
	// private void RemoveSpecificResource(R_Item itemDef, int amount) {
	// 	foreach (Slot slot in inventorySlots) {
	// 		while (!slot.IsEmpty() && amount > 0) {
	// 			slot.RemoveItem(itemDef);
	// 			amount -= 1;
	// 		}
	// 	}
	// }
}
