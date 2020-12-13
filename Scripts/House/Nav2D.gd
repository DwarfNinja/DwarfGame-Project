extends Navigation2D

var scent_scene =  preload("res://Scenes/Scent.tscn")

func _ready():
	Events.connect("request_roamcell", self, "_on_request_roamcell")
	Events.connect("request_navpath", self, "_on_request_navpath")
	Events.connect("remove_scent", self, "_on_remove_scent")
	$ScentTimer.connect("timeout", self, "place_player_scent")
	
func _on_request_roamcell(villager_id):
	var Villager = villager_id
	var villager_spawn_position = $Walls.world_to_map(Villager.spawn_cell)
	var villager_roam_destinations = []
	for cell in $Area.get_used_cells():
		if cell.distance_to(villager_spawn_position) > 10:
			villager_roam_destinations.append($Area.map_to_world(cell) + Vector2(8,8))
				
	villager_roam_destinations.shuffle()
	Villager.random_roamcell = (villager_roam_destinations.pop_front())

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
