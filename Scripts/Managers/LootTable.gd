extends Node

#	____Loot____
var iron = preload("res://Resources/Resources/Wood.tres")
var wood = preload("res://Resources/Resources/Iron.tres")
var goldcoins = preload("res://Resources/Resources/GoldCoins.tres")

#	____Lootables____
var chest = preload("res://Scenes/Interactables/Chest.tscn")

# Loot by total_drop_chance (drop_chance)
var loot_list = [
  {
	item = iron,
	drop_chance = iron.drop_chance #50
  },
  {
	item = wood,
	drop_chance = wood.drop_chance #50
  },
  {
	item = goldcoins,
	drop_chance = goldcoins.drop_chance #10
  },
]


var total_drop_chance = 0

func _init():
  # Calculate total total_drop_chance and accumulate the total_drop_chance for each item
	for i in loot_list:
		total_drop_chance += i.drop_chance
		i.drop_chance = total_drop_chance
#	var loot = select_random_item()
#	print(loot)

func select_random_item():
	randomize()
	var rng = randi() % total_drop_chance
	for i in loot_list:
	# if the RNG is <= item cumulated total_drop_chance then drop that item
		if rng <= i.drop_chance:
			return i.item
	return null
