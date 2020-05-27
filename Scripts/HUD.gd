extends CanvasLayer

onready var HboxContainer = $VBoxContainer/CenterContainer/InventoryBar/HBoxContainer
onready var GoldCoins = $VBoxContainer/Labels/HBoxContainer/GoldCoins


var count_1 = preload("res://Sprites/Count_1.png")
var count_2 = preload("res://Sprites/Count_2.png")
var count_3 = preload("res://Sprites/Count_3.png")
var count_4 = preload("res://Sprites/Count_4.png")


var inventory_items = {
	"wood": 0,
	"iron": 0,
	"coins": 0
}

var selector_position = 0


func _ready():
	# Connect Signals
	Events.connect("item_picked_up", self, "_on_item_picked_up")
	Events.connect("item_placed", self, "_on_item_placed")
	

func _process(_delta):
	# Test prints
	var selected_slot = get_node("VBoxContainer/CenterContainer/InventoryBar/HBoxContainer/Slot_" + str(selector_position))
	
	if Input.is_action_just_pressed("key_leftclick"):
		get_item_in_slot(selected_slot)
	if selected_slot.item_count_in_slot == 0:
		get_item_in_slot(selected_slot)
		
	# Clears all items in inventory
	if Input.is_action_just_pressed("ui_accept"):
		pass
#		for slot in HboxContainer.get_children():
#			slot.clear()
#			inventory_items["wood"] = 0
#			inventory_items["iron"] = 0
			
	# Determines Selector position based on scroll wheel movement
	if Input.is_action_just_released("scroll_up"):
			selector_position += 1
			if selector_position > 5:
				selector_position = 5
	elif Input.is_action_just_released("scroll_down"):
			selector_position -= 1
			if selector_position < 0:
				selector_position = 0
	
	# Iterates over all the slots and determines if it is the slot selected,
	# all other slot's selectors are turned off
	for index in range(0, HboxContainer.get_children().size()):
		var slot = HboxContainer.get_children()[index]
		if index == selector_position:
			slot.activate_selector()
		else:
			slot.deactivate_selector()

func _on_item_picked_up(item_def):
	if item_def.item_name == "coins":
		add_to_inventory(item_def)
		return
	# If the slot is empty, set the item definition. If the is not full but the item is the same, add the item
	for slot in HboxContainer.get_children():
		if slot.is_empty():
			slot.set_item(item_def)
			add_to_inventory(item_def)
			return
		elif slot.is_full() == false:
			if slot.item_def == item_def:
				slot.set_item(item_def)
				add_to_inventory(item_def)
				return
		
		
func add_to_inventory(item_def):
	inventory_items[str(item_def.item_name)] += item_def.item_count
	update_hud_coins()
	
func get_item_in_slot(selected_slot):
	var item_in_selected_slot = null
	if selected_slot.item_def:
		item_in_selected_slot = selected_slot.item_def
	Events.emit_signal("item_selected", item_in_selected_slot)
	return selected_slot
	
func _on_item_placed(selected_item):
	inventory_items[str(selected_item.item_name)] -= -1
	for slot in HboxContainer.get_children():
		if slot.get_name() == "Slot_" + str(selector_position):
			slot.remove_item()
			
func update_hud_coins():
	GoldCoins.text = str(inventory_items["coins"])
	
