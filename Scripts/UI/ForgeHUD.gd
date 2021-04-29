extends TextureRect

var iron = preload("res://Resources/Entities/Resources/Iron.tres")
onready var IronAmountHSlider = $IronAmountHSlider
onready var IronAmountLabel = $IronAmountLabel

var forge_opened = false
var current_opened_forge = null
var slider_iron_amount = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("open_forge", self, "_on_open_forge")
	Events.connect("close_forge", self, "_on_close_forge")

func _process(_delta):
	if forge_opened == true:
		if Input.is_action_just_pressed("key_e"):
			insert_iron()
		elif Input.is_action_just_pressed("key_esc"):
				Events.emit_signal("close_forge")

func insert_iron():
	if HUD.InventoryBar.inventory_dic["iron"] >= slider_iron_amount:
		Events.emit_signal("iron_amount_set", current_opened_forge, slider_iron_amount)
		IronAmountHSlider.editable = false
		HUD.InventoryBar.inventory_dic["iron"] -= slider_iron_amount
		HUD.InventoryBar.remove_specific_resource(iron, slider_iron_amount)
	else:
		print("NOT ENOUGH RESOURCES!")

func _on_HSlider_value_changed(_value):
	slider_iron_amount = IronAmountHSlider.value
	IronAmountLabel.text = str(IronAmountHSlider.value)

func _on_open_forge(_current_opened_forge):
	visible = true
	current_opened_forge = _current_opened_forge
	IronAmountHSlider.editable = true
	forge_opened = true
	HUD.menu_open = true
	
func _on_close_forge():
	visible = false
	forge_opened = false
	HUD.menu_open = false

