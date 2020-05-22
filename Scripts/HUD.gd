extends CanvasLayer

onready var Player = get_node("../YSort/Player")
onready var InventoryBar = $VBoxContainer/CenterContainer/InventoryBar
var wood = preload("res://HUDWood.png")
var stone = preload("res://icon.png")

var count_1 = preload("res://Count_1.png")
var count_2 = preload("res://Count_2.png")
var count_3 = preload("res://Count_3.png")
var count_4 = preload("res://Count_4.png")

var min_slot = 0

var inventory_items = {
	"wood": 0,
	"stone": 0,
	"gold":0
}


func _ready():
	#Connect Signals
	Events.connect("item_picked_up", self, "_on_item_picked_up")
	

func _process(delta):
	pass
	

func _on_item_picked_up(item_name, item_count):
	
	if inventory_items["wood"] + inventory_items["stone"]  < 24:
		inventory_items[str(item_name)] += 1
		print(inventory_items[str(item_name)])
	else:
		print("Your inventory is full!")
	
	
	for slots in range(0, get_node("VBoxContainer/CenterContainer/InventoryBar").get_children().size()):
		var slot = get_node("VBoxContainer/CenterContainer/InventoryBar").get_node("Slot_" + str(slots))
		if slot.texture == get(str(item_name)) :
			if slot.get_node("ItemCount").texture != get("count_" + "4"):
				slot.get_node("ItemCount").texture = get("count_" + str(inventory_items[str(item_name)]))
				return
				
		elif slot.texture == null:
				slot.texture = get(str(item_name))
				return
		
#func get_count_texture(item_count):
#	match item_count:
#		1: return count_1
#		2: return count_2
#		3: return count_3
