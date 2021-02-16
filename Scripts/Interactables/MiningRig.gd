extends Craftable_Object

var gold_coins = preload("res://Resources/Resources/GoldCoins.tres")
onready var MiningTimer = $MiningTimer
const GOLDCOINS_SCENE = preload("res://Scenes/Resources/GoldCoins.tscn")

var gold_coins_1 = preload("res://Sprites/Interactables/MiningRig/MiningRig TopDown Coins1.png")
var gold_coins_2 = preload("res://Sprites/Interactables/MiningRig/MiningRig TopDown Coins2.png")


var miningTimer_timedout = false
var goldcoins_in_mine = 0
var goldcoins_count = gold_coins.item_count

func _ready():
	# Connect signals
	MiningTimer.connect("timeout", self, "_on_MiningTimer_timeout")

func _process(_delta):
	update_goldcoin_sprite()
	
func interact():
	if goldcoins_in_mine > 0:
		Events.emit_signal("item_picked_up", gold_coins)
		goldcoins_in_mine -= 1
	else:
		print("MiningRig is empty!")

func _on_MiningTimer_timeout():
	if goldcoins_in_mine < 2:
		goldcoins_in_mine += 1
	
func update_goldcoin_sprite():
	if goldcoins_in_mine > 0:
		$GoldCoins.texture = get("gold_coins_" + str(goldcoins_in_mine))
	else:
		$GoldCoins.texture = null
