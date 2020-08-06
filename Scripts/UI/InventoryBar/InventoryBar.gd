extends TextureRect

onready var HboxContainer = $HBoxContainer

var count_1 = preload("res://Sprites/Count_1.png")
var count_2 = preload("res://Sprites/Count_2.png")
var count_3 = preload("res://Sprites/Count_3.png")
var count_4 = preload("res://Sprites/Count_4.png")

var selector_position = 0
var ui_menu_opened = false

func _ready():
	# Craftingtable signals
	Events.connect("entered_craftingtable", self, "_on_entered_craftingtable")
	Events.connect("exited_craftingtable", self, "_on_exited_craftingtable")
	# Forge signals
	Events.connect("entered_forge", self, "_on_entered_forge")
	Events.connect("exited_forge", self, "_on_exited_forge")

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
					selector_position = 5
		elif Input.is_action_just_released("scroll_down"):
				selector_position -= 1
				if selector_position < 0:
					selector_position = 0
				
				
	var selected_slot = get_node("HBoxContainer/Slot_" + str(selector_position))
	
	if ui_menu_opened == false:
		if Input.is_action_just_pressed("key_leftclick"):
			get_item_in_slot(selected_slot)
		if selected_slot.item_count_in_slot == 0:
			get_item_in_slot(selected_slot)
					
		# Iterates over all the slots and determines if it is the slot selected,
		# all other slot's selectors are turned off
		for index in range(0, HboxContainer.get_children().size()):
			var slot = HboxContainer.get_children()[index]
			if index == selector_position:
				slot.activate_selector()
			else:
				slot.deactivate_selector()


func get_item_in_slot(selected_slot):
	var item_in_selected_slot = null
	if selected_slot.item_def:
		item_in_selected_slot = selected_slot.item_def
	Events.emit_signal("item_selected", item_in_selected_slot)
	return selected_slot
	

# If the slot is empty, set the item definition. If the is not full but the item is the same, add the item
func add_item(item_def):
	for slot in HboxContainer.get_children():
		if slot.is_empty():
			slot.set_item(item_def)
			return
		elif slot.is_full() == false:
			if slot.item_def == item_def:
				slot.set_item(item_def)
				return
				

func remove_item():
	for slot in HboxContainer.get_children():
		if slot.get_name() == "Slot_" + str(selector_position):
			slot.remove_item()
			
# Can be simplified I think
func remove_required_resources(crafted_item):
	for slot in HboxContainer.get_children():
		if slot.item_def != null:
			if slot.item_def.item_name == "wood":
				for amount in crafted_item.wood_cost:
					slot.remove_item()
			elif slot.item_def.item_name == "iron":
				for amount in crafted_item.iron_cost:
					slot.remove_item()
					

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

