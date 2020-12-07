extends Navigation2D

var scent_scene =  preload("res://Scenes/Scent.tscn")

#var path : PoolVector2Array #DEBUG
#var goal : Vector2
#var roam_cell

func _ready():
	Events.connect("request_roamcell", self, "_on_request_roamcell")
	Events.connect("request_navpath", self, "_on_request_navpath")
	Events.connect("remove_scent", self, "_on_remove_scent")
	$ScentTimer.connect("timeout", self, "place_player_scent")

#func _input(event: InputEvent): #DEBUG
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_LEFT and event.pressed:
#			goal = get_local_mouse_position()
#			print(goal)
#			path = get_simple_path(goal, roam_cell, false)
#			$Line2D.points = PoolVector2Array(path)
#			$Line2D.show()
			
func _on_request_roamcell(villager_id):
	var Villager = villager_id
	var villager_spawn_position = $Area.world_to_map(Villager.spawn_position)
	var villager_roam_destinations = []
	for cell in $Area.get_used_cells():
		if cell.distance_to(villager_spawn_position) > 10:
			villager_roam_destinations.append($Area.map_to_world(cell) + Vector2(7.99, 8.01)) #Bug in Nav2D where it rounds up ints?
				
	villager_roam_destinations.shuffle()
	var roam_cell = (villager_roam_destinations.pop_front())
	$Indexes.set_cellv($Area.world_to_map(roam_cell), 14) #DEBUG
	Villager.random_roamcell = roam_cell
	
func _on_request_navpath(villager_id, target_cell):
	var Villager = villager_id
	var path = get_simple_path(Villager.global_position, target_cell, false)
	print(path)
	var inverse_path = path
	inverse_path.invert()
	Villager.path = PoolVector2Array(path)
	Villager.inverse_path = PoolVector2Array(inverse_path)
	$Line2D.points = PoolVector2Array(path)
	$Line2D.show()
	
func place_player_scent():
	var scent = scent_scene.instance()
	scent.player = $Walls/Player
	scent.position = $Walls/Player.position
	$Walls.add_child(scent)
	$Walls/Player.scent_trail.push_front(scent)
	
func _on_remove_scent(scent):
	$Walls/Player.scent_trail.erase(scent)
