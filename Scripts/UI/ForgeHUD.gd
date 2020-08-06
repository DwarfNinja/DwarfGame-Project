extends TextureRect

var iron = load("res://Resources/Iron.tres")
onready var IronAmountHSlider = $IronAmountHSlider
onready var IronAmountLabel = $IronAmountLabel

var forge_opened = false
var current_opened_forge = null
var slider_iron_amount = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("entered_forge", self, "_on_entered_forge")
	Events.connect("exited_forge", self, "_on_exited_forge")

func _process(_delta):
	if forge_opened == true:
		if Input.is_action_just_pressed("key_e"):
			insert_iron()

func insert_iron():
	if HUD.inventory_items["iron"] >= slider_iron_amount:
		Events.emit_signal("iron_amount_set", current_opened_forge, slider_iron_amount)
		IronAmountHSlider.editable = false
		HUD.inventory_items["iron"] -= slider_iron_amount
		HUD.InventoryBar.remove_specific_resource(iron, slider_iron_amount)
	else:
		print("NOT ENOUGH RESOURCES!")

func _on_HSlider_value_changed(value):
	slider_iron_amount = IronAmountHSlider.value
	IronAmountLabel.text = str(IronAmountHSlider.value)

func _on_entered_forge(_current_opened_forge):
	forge_opened = true
	current_opened_forge = _current_opened_forge
	IronAmountHSlider.editable = true
	
func _on_exited_forge():
	forge_opened = false

