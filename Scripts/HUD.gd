extends CanvasLayer

onready var player = get_node("../YSort/Player")


func _ready():
	#Connect Signals
	player.connect("wood_picked_up", self, "_on_wood_picked_up")
	
func _on_wood_picked_up():
	$VBoxContainer/CenterContainer/InventoryBar/HUDWoodenLogs.visible = true
