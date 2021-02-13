extends Node

# Item pickup/inventory signals
signal item_picked_up(item_def)
signal item_selected(item_in_selected_slot)
signal item_deselected()
signal place_item(selected_item)
signal item_placed(selected_item)

# Craftingtable signals
signal open_craftingtable()
signal close_craftingtable()

# Forge signals
signal open_forge(current_opened_forge)
signal close_forge()
signal iron_amount_set(current_opened_forge, slider_iron_amount)

signal entered_shop()
signal exited_shop()

signal entered_blackmarket()
signal exited_blackmarket()

# Mouse entered craftingtablebutton signal
signal craftingbutton_mouse_entered()

# ----------------------
signal exited_cave()
signal entered_cave()

# RandomGenHouse signals
signal randomgenhouse_loaded()

signal taxtimer_is_25_percent()
signal taxtimer_restarted()

signal request_navpath()
signal request_roamcell(villager_id)

signal update_playerghost(last_known_playerposition)
