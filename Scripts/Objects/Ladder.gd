extends StaticBody2D

var can_interact = false
onready var InteractArea = $InteractArea
onready var HouseScene = "res://Scenes/House.tscn"

func _ready():
	InteractArea.connect("area_entered", self, "_on_InteractArea_area_entered")
	InteractArea.connect("area_exited", self, "_on_InteractArea_area_exited")

func _process(_delta):
	if is_visible_in_tree():
		if can_interact == true:
			if Input.is_action_just_pressed("key_e"):
				Events.emit_signal("exited_cave")

func _on_InteractArea_area_entered(area):
	if area.get_name() == "PlayerInteractArea":
		can_interact = true
		$LadderSprite.material.set_shader_param("outline_color", Color(240,240,240,255))
		

func _on_InteractArea_area_exited(area):
	if area.get_name() == "PlayerInteractArea":
		can_interact = false
		$LadderSprite.material.set_shader_param("outline_color", Color(240,240,240,0))

# Remove the current level
#var level = root.get_node("Level")
#root.remove_child(level)
#level.call_deferred("free")

# Add the next level
#var next_level_resource = load("res://path/to/scene.tscn)
#var next_level = next_level_resource.instance()
#root.add_child(next_level)
