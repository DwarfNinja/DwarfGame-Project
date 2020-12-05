extends StaticBody2D

var can_interact = false
onready var InteractArea = $InteractArea
onready var WhiteOutlineShader = preload("res://Shaders/WhiteOutlineShader.tres")

func _ready():
	# Connect signals
	InteractArea.connect("area_entered", self, "_on_InteractArea_area_entered")
	InteractArea.connect("area_exited", self, "_on_InteractArea_area_exited")
	

func _process(_delta):
	if can_interact == true:
		if Input.is_action_just_pressed("key_e"):
			Events.emit_signal("entered_craftingtable")
		if Input.is_action_just_pressed("key_esc"):
			Events.emit_signal("exited_craftingtable")


func _on_InteractArea_area_entered(area):
	can_interact = true
	$CraftingTableSprite.material.set_shader_param("outline_color", Color(240,240,240,255))
		

func _on_InteractArea_area_exited(area):
	can_interact = false
	$CraftingTableSprite.material.set_shader_param("outline_color", Color(240,240,240,0))
		
