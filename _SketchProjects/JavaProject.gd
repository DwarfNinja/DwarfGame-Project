extends Node

onready var Node1: Node2D = get_node("Node1") as Node2D
onready var Node2: Node2D = get_node("Folder/Sub-Folder/Node2") as Node2D


func _physics_process(delta: float) -> void:
	print("Hello world")
	
	
func my_func():
	.my_func()
	yield()
	yield(my_func(), "completed")
