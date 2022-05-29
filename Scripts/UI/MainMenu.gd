extends Control

onready var NewGameButton = $Menu/CenterContainer/CenterRow/Buttons/NewGame

func _ready():
	NewGameButton.connect("pressed", self, "_on_NewGameButton_pressed")
	HUD.MenuOpen = true

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://Scenes/Worlds/Cave/Cave.tscn")
	HUD.get_node("VBoxContainer").visible = true
	HUD.MenuOpen = false

