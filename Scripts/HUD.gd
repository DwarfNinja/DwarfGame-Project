extends CanvasLayer

onready var Player = get_node("../YSort/Player")
onready var InventoryBar = $VBoxContainer/CenterContainer/InventoryBar
var wood = preload("res://HUDWood.png")
var min_slot = 0


func _ready():
	#Connect Signals
	Player.connect("wood_picked_up", self, "_on_wood_picked_up")
	

func _process(delta):
	print(min_slot)
	
	

func _on_wood_picked_up():
	for slots in range(0, get_node("VBoxContainer/CenterContainer/InventoryBar").get_children().size()):
		var slot = get_node("VBoxContainer/CenterContainer/InventoryBar").get_node("Slot_" + str(slots))
		if slot.texture == null:
			slot.texture = wood
			return
		

