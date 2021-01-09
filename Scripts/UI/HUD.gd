extends CanvasLayer

onready var InventoryBar = $VBoxContainer/CenterContainer/InventoryBar
onready var GoldCoins = $VBoxContainer/Labels/HBoxContainer/GoldCoins
onready var CraftingTableHUD = $Control/CraftingTableHUD
onready var ForgeHUD = $Control/ForgeHUD
onready var TravelingScreen = $Control/TravelingScreen
onready var TaxTimer = $TaxTimer
onready var ScreenTimer = $ScreenTimer
onready var TaxTimerLabel = $VBoxContainer/Labels/HBoxContainer/TaxTimerLabel


var inventory_items = {
	"wood": 0,
	"iron": 0,
	"goldcoins": 0
}

var craftingtable_opened = false
var tax = 200
var TaxKnight_instanced

func _ready():
	# Connect Signals
	TaxTimer.connect("timeout", self, "_on_TaxTimer_timeout")
	ScreenTimer.connect("timeout", self, "_on_ScreenTimer_timeout")
	# Enter/Exit location signals
	Events.connect("exited_cave", self, "_on_exited_cave")
	# Item signals
	Events.connect("item_picked_up", self, "_on_item_picked_up")
	Events.connect("item_placed", self, "_on_item_placed")
	# Craftingtable signals
	Events.connect("entered_craftingtable", self, "_on_entered_craftingtable")
	Events.connect("exited_craftingtable", self, "_on_exited_craftingtable")
	# Forge signals
	Events.connect("entered_forge", self, "_on_entered_forge")
	Events.connect("exited_forge", self, "_on_exited_forge")
	# RandomGenHouse signals
	Events.connect("randomgenhouse_loaded", self, "_on_randomgenhouse_loaded")


func _process(_delta):
	update_taxtimer()
	if int(round(TaxTimer.time_left)) < int(round(TaxTimer.wait_time * 0.25)):
		Events.emit_signal("taxtimer_is_25_percent")
	if TaxTimer.is_stopped():
		Events.emit_signal("taxtimer_restarted")
		

func _on_item_picked_up(item_def):
	if item_def.item_name == "goldcoins":
		add_to_inventory(item_def)
		return
	add_to_inventory(item_def)
	InventoryBar.add_item(item_def)
	

func add_to_inventory(item_def):
	inventory_items[str(item_def.item_name)] += item_def.item_count
	update_hud_coins()
	

func update_hud_coins():
	GoldCoins.text = str(inventory_items["goldcoins"])

func update_taxtimer():
#	var hours = int(round(TaxTimer.time_left * 96)/3600)
#	var minutes = int(round(TaxTimer.time_left))%60
	var minutes = int(round(TaxTimer.time_left))/60
	var seconds = int(round(TaxTimer.time_left))%60
	
#	TaxTimerLabel.text = ("%02d : %02d" % [hours, minutes])
	TaxTimerLabel.text = ("%02d : %02d" % [minutes, seconds])

func _on_item_placed(selected_item):
	if selected_item.item_name in inventory_items:
		inventory_items[str(selected_item.item_name)] -= 1
	InventoryBar.remove_item()

func _on_TaxTimer_timeout():
	if inventory_items["goldcoins"] > 0:
		inventory_items["goldcoins"] -= tax
		update_hud_coins()
		TaxTimer.wait_time = TaxTimer.wait_time * 0.5
		TaxTimer.start()
		Events.emit_signal("taxtimer_restarted")
	else:
		print("Game Ended")

# Crafting Table Code
func _on_entered_craftingtable():
	CraftingTableHUD.visible = true
	
func _on_exited_craftingtable():
	CraftingTableHUD.visible = false

func _on_entered_forge(_current_opened_forge):
	ForgeHUD.visible = true

func _on_exited_forge():
	ForgeHUD.visible = false
	
func _on_exited_cave():
	if TaxTimer.is_stopped():
		TaxTimer.start()
	TravelingScreen.visible = true

func _on_randomgenhouse_loaded():
	ScreenTimer.start()

func _on_ScreenTimer_timeout():
	TravelingScreen.visible = false
