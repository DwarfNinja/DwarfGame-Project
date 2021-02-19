extends Node

# Item pickup/inventory signals
signal item_picked_up(item_def)
signal item_selected(item_in_selected_slot)
signal item_deselected()
signal place_object(selected_item)
signal remove_item(selected_item)
signal drop_item(seleted_item)

signal entered_pickuparea(target)

# Craftingtable signals
signal open_craftingtable()
signal close_craftingtable()

# Forge signals
signal open_forge(current_opened_forge)
signal close_forge()
signal iron_amount_set(current_opened_forge, slider_iron_amount)

# Shop signals
signal entered_shop()
signal exited_shop()

# Blackmarket signals
signal entered_blackmarket()
signal exited_blackmarket()

signal taxtimer_is_25_percent()
signal taxtimer_restarted()

# Mouse entered craftingtablebutton signal
signal craftingbutton_mouse_entered()

# Cave signals
signal exited_cave()
signal entered_cave()

# RandomGenHouse signals
signal randomgenhouse_loaded()

signal request_navpath()
signal request_roamcell(villager_id)

signal update_playerghost(last_known_playerposition)
