extends Node

# Item pickup/inventory signals
signal item_picked_up(item_def)
signal item_selected(item_in_selected_slot)
signal item_placed(selected_item)

# Craftingtable signals
signal entered_craftingtable()
signal exited_craftingtable()
signal craftingtable_opened()

# Forge signals
signal entered_forge(current_opened_forge)
signal exited_forge()
signal iron_amount_set(current_opened_forge, current_iron_amount)

# Mouse entered craftingtablebutton signal
signal craftingbutton_mouse_entered()

# ----------------------
signal exited_cave()
signal entered_cave()

signal taxtimer_is_25_percent()
signal taxtimer_restarted()
