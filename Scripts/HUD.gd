extends CanvasLayer

onready var Player = get_node("../YSort/Player")
onready var HboxContainer = $VBoxContainer/CenterContainer/InventoryBar/HBoxContainer


var count_1 = preload("res://Sprites/Count_1.png")
var count_2 = preload("res://Sprites/Count_2.png")
var count_3 = preload("res://Sprites/Count_3.png")
var count_4 = preload("res://Sprites/Count_4.png")

var inventory_items = {
	"wood": 0,
	"iron": 0,
	"gold":0
}

var selector_position = 0


func _ready():
	# Connect Signals
	Events.connect("item_picked_up", self, "_on_item_picked_up")
	

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		for slot in HboxContainer.get_children():
			slot.clear()
	# Determines Selector position based on scroll wheel movement:
	if Input.is_action_just_released("scroll_up"):
			selector_position += 1
			if selector_position > 5:
				selector_position = 5
	elif Input.is_action_just_released("scroll_down"):
			selector_position -= 1
			if selector_position < 0:
				selector_position = 0
	
	var count = 0
	for slot in HboxContainer.get_children():
		if count == selector_position:
			slot.activate_selector()
		else:
			slot.deactivate_selector()
		count += 1
		

func _on_item_picked_up(item_def):

	for slot in HboxContainer.get_children():
		if slot.is_empty():
			slot.set_item(item_def)
			return
		elif not slot.is_full():
			if slot.item_def == item_def:
				slot.set_item(item_def)
				return
	
