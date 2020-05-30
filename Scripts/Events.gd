extends Node

# Item pickup/inventory signals
signal item_picked_up(item_def)
signal item_selected(item_in_selected_slot)
signal item_placed(selected_item)

# Craftingtable signals
signal entered_craftingtable()
signal exited_craftingtable()
signal craftingtable_opened()

# Mouse entered craftingtablebutton signal
signal craftingbutton_mouse_entered()
