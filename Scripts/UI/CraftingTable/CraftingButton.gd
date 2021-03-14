tool
extends Button


export (Resource) var craftable_def setget set_craftable_def #R_Craftable

signal craftingbutton_mouse_entered(crafting_button)

func _ready():
	icon = craftable_def.blueprint_icon
	connect("pressed", self, "_on_Button_pressed")
	connect("mouse_entered", self, "_on_mouse_entered")

func set_craftable_def(_craftable_def):
	craftable_def = _craftable_def
	icon = craftable_def.blueprint_icon
	

func _on_Button_pressed():
	craft_item()
		
func _on_mouse_entered():
	Events.emit_signal("craftingbutton_mouse_entered", self)

func craft_item():
	var craftable_def_dupe = craftable_def.duplicate()
	Events.emit_signal("craft_item", craftable_def_dupe)
#	if HUD.InventoryBar.inventory_dic["wood"] >= craftable_def.wood_cost and HUD.InventoryBar.inventory_dic["iron"] >= craftable_def.iron_cost:
#		if HUD.InventoryBar.can_fit_in_inventory(craftable_def):
#			var crafted_item = craftable_def.duplicate()
#			remove_required_resources(crafted_item)
#			HUD.InventoryBar.add_item(craftable_def)
#
#	else:
#		print("NOT ENOUGH RESOURCES!")
	
func remove_required_resources(crafted_item):
	HUD.InventoryBar.inventory_dic["wood"] -= crafted_item.wood_cost
	HUD.InventoryBar.inventory_dic["iron"] -= crafted_item.iron_cost
	HUD.InventoryBar.remove_required_resources(crafted_item)

func activate_crafting_selector():
	$Selector.show()
	$AnimationPlayer.current_animation = "Crafting Selector Selecting"
	
func deactivate_crafting_selector():
	$AnimationPlayer.current_animation = "Crafting Selector Idle"
	$Selector.hide()
