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
	Events.emit_signal("craft_item", craftable_def)

func remove_required_resources(crafted_item):
	HUD.InventoryBar.remove_required_resources(crafted_item)

func activate_crafting_selector():
	$Selector.show()
	$AnimationPlayer.current_animation = "Crafting Selector Selecting"
	
func deactivate_crafting_selector():
	$AnimationPlayer.current_animation = "Crafting Selector Idle"
	$Selector.hide()
