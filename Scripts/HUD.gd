extends CanvasLayer

onready var InventoryBar = $VBoxContainer/CenterContainer/InventoryBar
onready var GoldCoins = $VBoxContainer/Labels/HBoxContainer/GoldCoins
onready var CraftingTable = $CraftingTableHUD


var inventory_items = {
	"wood": 0,
	"iron": 0,
	"coins": 0
}

var craftingtable_opened = false


func _ready():
	# Connect Signals
	Events.connect("item_picked_up", self, "_on_item_picked_up")
	Events.connect("item_placed", self, "_on_item_placed")
	Events.connect("entered_craftingtable", self, "_on_entered_craftingtable")
	Events.connect("exited_craftingtable", self, "_on_exited_craftingtable")
	

func _process(_delta):
	pass

func _on_item_picked_up(item_def):
	if item_def.item_name == "coins":
		add_to_inventory(item_def)
		return
	InventoryBar.add_item(item_def)
	add_to_inventory(item_def)
	
		
func add_to_inventory(item_def):
	inventory_items[str(item_def.item_name)] += item_def.item_count
	update_hud_coins()
	

func update_hud_coins():
	GoldCoins.text = str(inventory_items["coins"])


func _on_item_placed(selected_item):
	if selected_item.item_name in inventory_items:
		inventory_items[str(selected_item.item_name)] -= 1
	InventoryBar.remove_item()


# Crafting Table Code
func _on_entered_craftingtable():
	CraftingTable.visible = true
	
func _on_exited_craftingtable():
	CraftingTable.visible = false
	
