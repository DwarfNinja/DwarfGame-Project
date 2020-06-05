extends CanvasLayer

onready var InventoryBar = $VBoxContainer/CenterContainer/InventoryBar
onready var GoldCoins = $VBoxContainer/Labels/HBoxContainer/GoldCoins
onready var CraftingTableHUD = $CraftingTableHUD
onready var ForgeHUD = $ForgeHUD


var inventory_items = {
	"wood": 0,
	"iron": 0,
	"goldcoins": 0
}

var craftingtable_opened = false


func _ready():
	# Connect Signals
	Events.connect("item_picked_up", self, "_on_item_picked_up")
	Events.connect("item_placed", self, "_on_item_placed")
	# Craftingtable signals
	Events.connect("entered_craftingtable", self, "_on_entered_craftingtable")
	Events.connect("exited_craftingtable", self, "_on_exited_craftingtable")
	# Forge signals-
	Events.connect("entered_forge", self, "_on_entered_forge")
	Events.connect("exited_forge", self, "_on_exited_forge")
	

func _process(_delta):
	pass

func _on_item_picked_up(item_def):
	if item_def.item_name == "goldcoins":
		add_to_inventory(item_def)
		return
	InventoryBar.add_item(item_def)
	add_to_inventory(item_def)
	
		
func add_to_inventory(item_def):
	inventory_items[str(item_def.item_name)] += item_def.item_count
	update_hud_coins()
	

func update_hud_coins():
	GoldCoins.text = str(inventory_items["goldcoins"])


func _on_item_placed(selected_item):
	if selected_item.item_name in inventory_items:
		inventory_items[str(selected_item.item_name)] -= 1
	InventoryBar.remove_item()


# Crafting Table Code
func _on_entered_craftingtable():
	CraftingTableHUD.visible = true
	
func _on_exited_craftingtable():
	CraftingTableHUD.visible = false

func _on_entered_forge(_current_opened_forge):
	ForgeHUD.visible = true

func _on_exited_forge():
	ForgeHUD.visible = false
