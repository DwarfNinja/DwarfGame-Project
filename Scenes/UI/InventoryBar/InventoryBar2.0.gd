extends MarginContainer


onready var HboxContainer = $SlotContainer/HBoxContainer

func _ready():
	Events.connect("update_slot", self, "_on_update_slot")
	Events.connect("update_slot_selectors", self, "_on_update_slot_selectors")


func _on_update_slot_selectors(selector_position, selected_slot):
		# Iterates over all the slots and determines if it is the slot selected,
	# all other slot's selectors are turned off
	for index in range(0, HboxContainer.get_children().size()):
		var slot = HboxContainer.get_children()[index]
		if index == selector_position:
			activate_selector(slot, selected_slot)
		else:
			deactivate_selector(slot)


func _on_update_slot(slot, item_def, count):
	var Slot = get_node("SlotContainer/HBoxContainer/" + slot)
	if item_def:
		Slot.texture = item_def.hud_texture
		Slot.get_node("ItemCount").text = str(count)
	else:
		Slot.texture = null
		Slot.get_node("ItemCount").text = null
	

func activate_selector(slot, selected_slot):
	var slot_selector = slot.get_node("Selector")
	slot_selector.show()
	if slot == selected_slot:
		slot_selector.get_node("AnimationPlayer").current_animation = "Selector Selecting"
	else:
		slot_selector.get_node("AnimationPlayer").current_animation = "Selector Idle"

func deactivate_selector(slot):
	var slot_selector = slot.get_node("Selector")
	slot_selector.hide()
	slot_selector.get_node("AnimationPlayer").current_animation = "Selector Idle"
