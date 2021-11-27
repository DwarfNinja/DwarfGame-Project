using Godot;
using System;
using System.Collections.Generic;
using Dictionary = Godot.Collections.Dictionary;

public class Inventory : Node2D {

	private Resource goldcoins = ResourceLoader.Load("res://Resources/Entities/Resources/GoldCoins.tres");

	private Dictionary<string, Dictionary<string, object>> inventorySlots =
		new Dictionary<string, Dictionary<string, object>> {
			["Slot_0"] = new Dictionary<string, object> {
				["itemDef"] = null, ["count"] = 0
			},
			["Slot_1"] = new Dictionary<string, object> {
				["itemDef"] = null, ["count"] = 0
			},
			["Slot_2"] = new Dictionary<string, object> {
				["itemDef"] = null, ["count"] = 0
			},
			["Slot_3"] = new Dictionary<string, object> {
				["itemDef"] = null, ["count"] = 0
			},
			["Slot_4"] = new Dictionary<string, object> {
				["itemDef"] = null, ["count"] = 0
			},
			["Slot_5"] = new Dictionary<string, object> {
				["itemDef"] = null, ["count"] = 0
			}
		};

	private Dictionary<Resource, int> playerItems;

	private int selectorPosition = 0;
	private R_Item selectedItem;
	private string selectedSlot;

	public override void _Ready() {
		Events.ConnectEvent("ItemPickedUp", this, "OnItemPickedUp");
		Events.ConnectEvent("CraftItem", this, "OnCraftItem");
		Events.ConnectEvent("RemoveItem", this, "OnRemoveItem");
		Events.EmitEvent(nameof(Events.UpdateSlotSelectors), selectorPosition, selectedSlot);
		
		playerItems = new Dictionary<Resource, int>() {
			[goldcoins] =  0,
		};
	}

	public override void _Process(float delta) {
		string currentSlot = "Slot_" + selectorPosition;

		if (HUD.MenuOpen == false) {
			if (GetTree().CurrentScene.Name == "Cave") {
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
					Events.EmitEvent(nameof(Events.DropItem), GetItemInSlot(currentSlot));
				}
			}
		}
	}

	private void SelectSlot(string currentSlot) {
		selectedSlot = currentSlot;
		selectedItem = GetItemInSlot(currentSlot);
		Events.EmitEvent(nameof(Events.UpdateSlotSelectors), selectorPosition, selectedSlot);
	}

	private void DeselectSlot() {
		selectedSlot = null;
		selectedItem = null;
		Console.WriteLine("CHEESE");
		Events.EmitEvent(nameof(Events.UpdateSlotSelectors), selectorPosition, selectedSlot);
	}

	private R_Item GetItemInSlot(string slot) {
		return (R_Item) inventorySlots[slot]["itemDef"];
	}

	private void _on_item_picked_up(R_Item itemDef) {
		AddItem(itemDef);
	}

	private void AddItem(R_Item itemDef) {
		if (playerItems.ContainsKey(itemDef)) {
			AddToPlayerItems(itemDef);
			return;
		}

		foreach (string slot in inventorySlots.Keys) {
			if (SlotHasItem(slot, itemDef) && !SlotIsFull(slot)) {
				AddToSlot(slot, itemDef);
				return;
			}
		}
		
		foreach (string slot in inventorySlots.Keys) {
			if (SlotIsEmpty(slot)) {
				AddToSlot(slot, itemDef);
				return;
			}
		}
	}

	private void AddToPlayerItems(R_Item itemDef) {
		playerItems[itemDef] += 1;
		if (itemDef == goldcoins) {
			HUD.UpdateHudCoins(playerItems[goldcoins]);
		}
	}

	private void AddToSlot(string slot, R_Item itemDef) {
		inventorySlots[slot]["itemDef"] = itemDef;
		inventorySlots[slot]["count"] = (int) inventorySlots[slot]["count"] + 1;
		Events.EmitEvent(nameof(Events.UpdateSlot), slot, itemDef, inventorySlots[slot]["count"]);
	}

	private bool SlotHasItem(string slot, R_Item itemDef) {
		return inventorySlots[slot]["itemDef"] == itemDef;
	}
	
	private bool SlotIsFull(string slot) {
		return (int) inventorySlots[slot]["count"] >= 4;
	}
	
	private bool SlotIsEmpty(string slot) {
		return (int) inventorySlots[slot]["count"] <= 0;
	}
}
