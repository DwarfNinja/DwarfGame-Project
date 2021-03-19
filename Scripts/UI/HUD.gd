extends CanvasLayer

onready var GoldCoins = $VBoxContainer/Labels/HBoxContainer/GoldCoins
onready var TravelingScreen = $Control/TravelingScreen
onready var ScreenTimer = $ScreenTimer
onready var DayTimeLabel = $VBoxContainer/Labels/HBoxContainer/DayTimeLabel

var menu_open = false

func _ready():
	# Connect Signals
	ScreenTimer.connect("timeout", self, "_on_ScreenTimer_timeout")
	# Enter/Exit location signals
	Events.connect("exited_cave", self, "_on_exited_cave")
	# RandomGenHouse signals
	Events.connect("randomgenhouse_loaded", self, "_on_randomgenhouse_loaded")


func update_hud_coins(inventory_goldcoins_amount):
	GoldCoins.text = str(inventory_goldcoins_amount)

func _on_exited_cave():
	GameManager.day_ended = false
	TravelingScreen.visible = true

func _on_randomgenhouse_loaded():
	ScreenTimer.start()

func _on_ScreenTimer_timeout():
	TravelingScreen.visible = false
