extends MarginContainer

onready var HboxContainer = $SlotContainer/HBoxContainer

var count_1 = preload("res://Sprites/HUD/InventoryBar/Count_1.png")
var count_2 = preload("res://Sprites/HUD/InventoryBar/Count_2.png")
var count_3 = preload("res://Sprites/HUD/InventoryBar/Count_3.png")
var count_4 = preload("res://Sprites/HUD/InventoryBar/Count_4.png")

var selector_position = 0
var item_is_selected = false
var ui_menu_opened = false

var inventory_dic = {
	"wood": 0,
	"iron": 0,
	"goldcoins": 0,
	"miningrig": 0,
	"forge": 0
}

func _ready():
	# Craftingtable signals
	Events.connect("entered_craftingtable", self, "_on_entered_craftingtable")
	Events.connect("exited_craftingtable", self, "_on_exited_craftingtable")
	# Forge signals
	Events.connect("entered_forge", self, "_on_entered_forge")
	Events.connect("exited_forge", self, "_on_exited_forge")
	# Item signals
	Events.connect("item_picked_up", self, "_on_item_picked_up")
	Events.connect("item_placed", self, "_on_item_placed")

func _process(_delta):
	# Clears all items in inventory
	if Input.is_action_just_pressed("ui_accept"):
		pass
#		for slot in HboxContainer.get_children():
#			slot.clear()
#			inventory_items["wood"] = 0
#			inventory_items["iron"] = 0
			
	# Determines Selector position based on scroll wheel movement
	if ui_menu_opened == false:
		if Input.is_action_just_released("scroll_up"):
			selector_position += 1
			if selector_position > 5:
				selector_position = 0
			clear_item_selection()
		elif Input.is_action_just_released("scroll_down"):
			selector_position -= 1
			if selector_position < 0:
				selector_position = 5
			clear_item_selection()
				
	var Selected_Slot = get_node("SlotContainer/HBoxContainer/Slot_" + str(selector_position))
	
	if ui_menu_opened == false:
		if Input.is_action_just_pressed("f"):
			if item_is_selected == false:
				if get_item_in_slot(Selected_Slot).type_name == "craftable":
					select_item(Selected_Slot)
			elif item_is_selected == true:
				clear_item_selection()
		if item_is_selected == true:
			select_item(Selected_Slot)

		# Iterates over all the slots and determines if it is the slot selected,
		# all other slot's selectors are turned off
		for index in range(0, HboxContainer.get_children().size()):
			var slot = HboxContainer.get_children()[index]
			if index == selector_position:
				slot.activate_selector()
			else:
				slot.deactivate_selector()


func get_item_in_slot(slot):
	return slot.item_def

func select_item(Selected_Slot):
	var item_in_Selected_Slot = get_item_in_slot(Selected_Slot)
	item_is_selected = true
	Events.emit_signal("item_selected", item_in_Selected_Slot, item_is_selected)
	
func clear_item_selection():
	item_is_selected = false
	Events.emit_signal("item_deselected", item_is_selected)
	
# If the slot is empty, set the item definition. If it is not full but the item is the same, add the item
#Used to be add_item()
func _on_item_picked_up(item_def):
	add_item(item_def)

func add_item(item_def):
	if item_def.item_name == "goldcoins":
		add_to_inventory_dic(item_def)
		return
	for slot in HboxContainer.get_children():
		if slot.is_empty():
			slot.set_item(item_def)
			add_to_inventory_dic(item_def)
			return
		elif slot.is_full() == false:
			if slot.has_resource(item_def):
				slot.set_item(item_def)
				add_to_inventory_dic(item_def)
				return
				
func can_fit_in_inventory(item_def):
	if item_def.item_name == "goldcoins":
		return true
	for slot in HboxContainer.get_children():
		if slot.is_empty():
			return true
		elif slot.is_full() == false:
			if slot.has_resource(item_def):
				return true
	return false

#TODO: Should remove inventory_dic and replace with function that checks for free space
func add_to_inventory_dic(item_def):
	inventory_dic[item_def.item_name] += item_def.item_count
	if item_def.item_name == "goldcoins":
		HUD.update_hud_coins(inventory_dic["goldcoins"])

#TODO: Should remove inventory_dic and replace with function that checks if it can remove items
func remove_from_inventory_dic(item_def):
	inventory_dic[item_def.item_name] -= item_def.item_count
	if item_def.item_name == "goldcoins":
		HUD.update_hud_coins(inventory_dic["goldcoins"])

#Used to be remove_item()
func _on_item_placed(selected_item):
	if selected_item.item_name in inventory_dic:
		inventory_dic[selected_item.item_name] -= 1
		for slot in HboxContainer.get_children():
			if slot.get_name() == "Slot_" + str(selector_position):
				slot.remove_item()


#Iterates through slots in Inventory backwards and removes resources == item_cost
#TODO: Can be improved | Could be changed to use slot.has_resources
func remove_required_resources(crafted_item):
	var Slots = HboxContainer.get_children()
	var Inverse_Slots = Slots.duplicate()
	Inverse_Slots.invert()
	for slot in Inverse_Slots:
		if slot.item_def != null:
			if slot.item_def.item_name == "wood":
				for amount in crafted_item.wood_cost:
					slot.remove_item()
					crafted_item.wood_cost -= 1
			elif slot.item_def.item_name == "iron":
				for amount in crafted_item.iron_cost:
					slot.remove_item()
					crafted_item.iron_cost -= 1


func remove_specific_resource(_specific_resource, amount):
	for slot in HboxContainer.get_children():
		if slot.item_def != null:
			var specific_resource = _specific_resource
			if slot.has_resources(specific_resource):
				for cycles in amount:
					slot.remove_item()


func _on_entered_craftingtable():
	ui_menu_opened = true

func _on_exited_craftingtable():
	ui_menu_opened = false
	
func _on_entered_forge(_current_opened_forge):
	ui_menu_opened = true

func _on_exited_forge():
	ui_menu_opened = false

