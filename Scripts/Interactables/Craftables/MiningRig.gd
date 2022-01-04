extends Interactable_Entity
var gold_coins = preload("res://Resources/Entities/Resources/GoldCoins.tres")
onready var MiningTimer = $MiningTimer

var gold_coins_1 = preload("res://Sprites/Interactables/Craftables/MiningRig/CoinsOne.png")
var gold_coins_2 = preload("res://Sprites/Interactables/Craftables/MiningRig/CoinsTwo.png")


var miningTimer_timedout = false
var goldcoins_in_mine = 0

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
