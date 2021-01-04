extends Control

func _on_NewGame_pressed():
	get_tree().change_scene("res://Scenes/Worlds/Cave.tscn")
	HUD.get_node("VBoxContainer").visible = true
