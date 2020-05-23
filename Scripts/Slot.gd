extends TextureRect

var item_count_in_slot = 0
var item_def: R_Item

var count_1 = preload("res://Sprites/Count_1.png")
var count_2 = preload("res://Sprites/Count_2.png")
var count_3 = preload("res://Sprites/Count_3.png")
var count_4 = preload("res://Sprites/Count_4.png")


func is_full():
	return item_count_in_slot >= 4
	
func is_empty():
	return item_count_in_slot <= 0
	
func set_item(_item_def):
	item_def = _item_def
	texture = item_def.hud_texture
	item_count_in_slot += 1
	get_node("ItemCount").texture = get("count_" + str(item_count_in_slot))
	
func clear():
	item_count_in_slot = 0
	item_def = null
	texture = null
	get_node("ItemCount").texture = null
	
func activate_selector():
	$Selector.show()
	if item_count_in_slot > 0:
		$Selector/AnimationPlayer.current_animation = "Selector Selecting"
	else:
		$Selector/AnimationPlayer.current_animation = "Selector Idle"
	
func deactivate_selector():
	$Selector/AnimationPlayer.current_animation = "Selector Idle"
	$Selector.hide()
	
