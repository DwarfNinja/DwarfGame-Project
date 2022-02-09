#extends Node2D
#
#onready var goldcoins = preload("res://Resources/Entities/Resources/GoldCoins.tres")
#
#onready var inventory_slots = {
#	"Slot_0": {"item_def": null, "count": 0},
#	"Slot_1": {"item_def": null, "count": 0},
#	"Slot_2": {"item_def": null, "count": 0},
#	"Slot_3": {"item_def": null, "count": 0},
#	"Slot_4": {"item_def": null, "count": 0},
#	"Slot_5": {"item_def": null, "count": 0},
#}
#
#onready var player_items = {
#	goldcoins: 0
#}
#
#var selector_position = 0
#var selected_item = null
#var selected_slot
#
#func _ready():
#	Events.connect("item_picked_up", self, "_on_item_picked_up")
#	Events.connect("craft_item", self, "_on_craft_item")
#	Events.emit_signal("update_slot_selectors", selector_position, selected_slot)
#	Events.connect("remove_item", self, "_on_remove_item")
#
#func _process(_delta):
#	var current_slot = "Slot_" + str(selector_position)
#
#	if HUD.menu_open == false:
#		if get_tree().get_current_scene().get_name() == "Cave":
#			if Input.is_action_just_pressed("key_leftclick"):
#				if get_item_in_slot(current_slot):
#					if get_item_in_slot(current_slot).type == R_Item.TYPE.CRAFTABLE:
#						select_slot(current_slot)
#
#			if Input.is_action_just_pressed("key_rightclick"):
#				if selected_item:
#					if selected_item.type == R_Item.TYPE.CRAFTABLE:
#						Events.emit_signal("place_object", selected_item)
#						select_slot(current_slot)
#
#		# Determines Selector position based on scroll wheel movement
#		if Input.is_action_just_released("scroll_up"):
#			selector_position += 1
#			if selector_position > 5:
#				selector_position = 0
#			deselect_slot()
#
#		elif Input.is_action_just_released("scroll_down"):
#			selector_position -= 1
#			if selector_position < 0:
#				selector_position = 5
#			deselect_slot()
#
#
#		if Input.is_action_just_pressed("key_q"):
#			if get_item_in_slot(current_slot):
#				Events.emit_signal("drop_item", get_item_in_slot(current_slot))
#
#		if Input.is_action_just_pressed("key_f"):
#			print(inventory_slots)
#
#
#func select_slot(current_slot):
#	selected_slot = current_slot
#	selected_item = get_item_in_slot(current_slot)
#	Events.emit_signal("update_slot_selectors", selector_position, selected_slot)
#
#func deselect_slot():
#	selected_slot = null
#	selected_item = null
#	Events.emit_signal("update_slot_selectors", selector_position, selected_slot)
#
#func get_item_in_slot(slot):
#	return inventory_slots[slot]["item_def"]
#
#func _on_item_picked_up(item_def):
#	add_item(item_def)
#
## If the slot is empty, set the item definition. If it is not full but the item is the same, add the item
#func add_item(item_def):
#	if item_def in player_items.keys():
#		add_to_player_items(item_def)
#		return
#	for slot in inventory_slots:
#		if slot_has_item(slot, item_def) and not slot_is_full(slot):
#			add_to_slot(slot, item_def)
#			return
#	for slot in inventory_slots:
#		if slot_is_empty(slot):
#			add_to_slot(slot, item_def)
#			return
#
#func can_fit_in_inventory(item_def):
#	if item_def in player_items:
#		return true
#	for slot in inventory_slots:
#		if slot_is_empty(slot):
#			return true
#		elif not slot_is_full(slot):
#			if slot_has_item(slot, item_def):
#				return true
#	return false
#
#
#func add_to_player_items(item_def):
#	player_items[item_def] += 1
#	if item_def == goldcoins:
#		HUD.update_hud_coins(player_items[goldcoins])
#
#
#func _on_remove_item(item_def):
#	if item_def in player_items:
#		player_items[item_def] -= 1
#		return
#	remove_from_slot("Slot_" + str(selector_position), item_def)
#
#func _on_use_item(item_def):
#	if item_in_player_items(item_def):
#		remove_required_items(item_def.required_items)
#		add_item(item_def)
#	else:
#		print("DOES NOT HAVE" + item_def + "!")
#
#func _on_craft_item(craftable_def):
#	if has_required_items_in_inventory(craftable_def):
#		remove_required_items(craftable_def.required_items)
#		add_item(craftable_def)
#	else:
#		print("NOT ENOUGH RESOURCES!")
#
#func add_to_slot(slot, item_def):
#	inventory_slots[slot]["item_def"] = item_def
#	inventory_slots[slot]["count"] += 1
#	Events.emit_signal("update_slot", slot, item_def, inventory_slots[slot]["count"])
#
#func remove_from_slot(slot, item_def):
#	if slot_is_empty(slot) == false:
#		inventory_slots[slot]["count"] -= 1
#	if slot_is_empty(slot):
#		inventory_slots[slot]["item_def"] = null
#	Events.emit_signal("update_slot", slot, item_def, inventory_slots[slot]["count"])
#
#
#func slot_has_item(slot, item_def):
#	return inventory_slots[slot]["item_def"] == item_def
#
#func slot_is_full(slot):
#	return inventory_slots[slot]["count"] >= 4
#
#func slot_is_empty(slot):
#	return inventory_slots[slot]["count"] <= 0
#
#
#func remove_required_items(_required_items):
#	var required_items = _required_items.duplicate()
#
#	var slot_list = inventory_slots.keys()
#	var inverse_slot_list = slot_list.duplicate()
#	inverse_slot_list.invert()
#
#	for slot in inverse_slot_list:
#		if inventory_slots[slot]["item_def"] == null:
#			continue
#		for required_item in required_items:
#			if slot_has_item(slot, required_item):
#				for amount in required_items[required_item]:
#					if inventory_slots[slot]["count"] > 0:
#						remove_from_slot(slot, required_item)
#						required_items[required_item] -= 1
#
#func item_in_inventoryslots(item):
#	for slot in inventory_slots:
#		if slot["item_def"]:
#			if slot_has_item(slot, item):
#				return true
#	return false
#
#func item_in_player_items(item):
#	for item in player_items:
#		if player_items.has(item):
#			return true
#	return false
#
#func has_required_items_in_inventory(_craftable_def):
#	var craftable_def = _craftable_def.duplicate()
#
#	for required_item in craftable_def.required_items:
#		for slot in inventory_slots:
#			if slot_has_item(slot, required_item):
#				craftable_def.required_items[required_item] -= inventory_slots[slot]["count"]
#		if craftable_def.required_items[required_item] > 0:
#			return false
#	return true
#
#func remove_specific_resource(_specific_item, amount):
#	for slot in inventory_slots:
#		if slot["item_def"]:
#			var specific_item = _specific_item
#			if slot_has_item(slot, specific_item):
#				for cycles in amount:
#					slot.remove_item()
