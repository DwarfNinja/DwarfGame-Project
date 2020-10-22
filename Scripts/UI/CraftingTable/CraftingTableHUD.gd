extends TextureRect

onready var Gridcontainer = $GridContainer

var crafting_selector_position = 0
var craftingtable_opened = false
onready var Selected_Button = get_node("GridContainer/CraftingButton_" + str(crafting_selector_position))

func _ready():
	# Craftingtable signals
	Events.connect("entered_craftingtable", self, "_on_entered_craftingtable")
	Events.connect("exited_craftingtable", self, "_on_exited_craftingtable")
	# Craftingbutton signal that signals if the mouse entered the button area
	Events.connect("craftingbutton_mouse_entered", self, "_on_craftingbutton_mouse_entered")
	

func _process(_delta):
	# Determines Selector position based on scroll wheel movement
	# --------LOOK AT LATER--------
	if craftingtable_opened == true:
		update_resourcebar()
		var hor_add = 2
		var vert_add = 1
		if Input.is_action_just_pressed("ui_right") or Input.is_action_just_released("scroll_up"):
			crafting_selector_position += hor_add
			if crafting_selector_position == 7:
				crafting_selector_position = 0
			elif crafting_selector_position == 6:
			 crafting_selector_position = 1
		
		if Input.is_action_just_pressed("ui_left"):
			crafting_selector_position -= hor_add
			if crafting_selector_position == -1:
				crafting_selector_position = 4
			elif crafting_selector_position == -2:
			 crafting_selector_position = 5
		
		if Input.is_action_just_pressed("ui_down") or Input.is_action_just_released("scroll_down"):
			crafting_selector_position += vert_add
			if crafting_selector_position == 6:
				crafting_selector_position = 0
		
		if Input.is_action_just_pressed("ui_up"):
			crafting_selector_position -= vert_add
			if crafting_selector_position < 0:
				crafting_selector_position = 5
		
#		if crafting_selector_position > 5:
#			if crafting_selector_position == 6 and add_value == 2:
#				crafting_selector_position = 1
#			if crafting_selector_position == 6 and add_value == 1:
#				crafting_selector_position = 0
#			if crafting_selector_position == 7:
#				crafting_selector_position = 0
					
				
	Selected_Button = get_node("GridContainer/CraftingButton_" + str(crafting_selector_position))
	
	if Input.is_action_just_pressed("key_e"):
		if craftingtable_opened == true:
				Selected_Button.craft_item()

	# Iterates over all buttons and determines if it the button is selected,
	# all other button's selectors are turned off
	for buttons in Gridcontainer.get_children():
		var button_number = int(buttons.get_name().split("CraftingButton_")[1])
		if button_number == crafting_selector_position:
			buttons.activate_crafting_selector()
		else:
			buttons.deactivate_crafting_selector()

func _on_craftingbutton_mouse_entered(crafting_button):
	crafting_selector_position = int(crafting_button.get_name().split("CraftingButton_")[1])
	
	
func update_resourcebar():
	var item_def_in_craftingbutton = Selected_Button.craftable_def
	$ResouceBar/WoodCostLabel.text = str(item_def_in_craftingbutton.wood_cost)
	$ResouceBar/IronCostLabel.text = str(item_def_in_craftingbutton.iron_cost)
	

func _on_entered_craftingtable():
	craftingtable_opened = true

func _on_exited_craftingtable():
	craftingtable_opened = false
