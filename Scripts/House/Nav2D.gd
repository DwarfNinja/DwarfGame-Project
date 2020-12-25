extends Navigation2D

onready var PlayerGhost = $Walls/PlayerGhost

var current_playerposition
var uptodate_last_known_playerpositon

func _ready():
	Events.connect("request_roamcell", self, "_on_request_roamcell")
	Events.connect("request_navpath", self, "_on_request_navpath")
	Events.connect("update_playerghost", self, "_on_update_lastknown_playerposition")
	$Walls/PlayerGhost/PlayerGhostArea.connect("body_entered", self, "_on_PlayerGhostArea_body_entered")
			
			
func _process(_delta):
	if get_node("Walls/Player") != null:
		current_playerposition = get_node("Walls/Player").get_global_position()
	
func _on_request_roamcell(Villager):
	var villager_spawn_position = $Area.world_to_map(Villager.spawn_position)
	var villager_roam_destinations = []
	for cell in $Area.get_used_cells():
		if cell.distance_to(villager_spawn_position) > 10:
			villager_roam_destinations.append($Area.map_to_world(cell) + Vector2(7.99, 8.01)) #Bug in Nav2D where it rounds up ints?
				
	villager_roam_destinations.shuffle()
	var roam_cell = (villager_roam_destinations.pop_front())
	$Indexes.set_cellv($Area.world_to_map(roam_cell), 14) #DEBUG
	Villager.random_roamcell = roam_cell
	
#func _on_request_navpath(Villager, target_cell):
#	var path = get_simple_path(Villager.global_position, target_cell, false)
#	print(path)
#	var inverse_path = path
#	inverse_path.invert()
#	Villager.path = PoolVector2Array(path)
#	Villager.inverse_path = PoolVector2Array(inverse_path)
#	$Line2D.points = PoolVector2Array(path)
#	$Line2D.show()
	
func _on_update_lastknown_playerposition(received_playerposition):
	if uptodate_last_known_playerpositon == null:
		uptodate_last_known_playerpositon = received_playerposition
	else:
		if received_playerposition.distance_to(current_playerposition) < uptodate_last_known_playerpositon.distance_to(current_playerposition):
			uptodate_last_known_playerpositon = received_playerposition
			
	PlayerGhost.global_position = uptodate_last_known_playerpositon
	PlayerGhost.visible = true
	
	for Villager in get_tree().get_nodes_in_group("Villager"):
#		if Villager.last_known_player_position != uptodate_last_known_playerpositon:
#			Villager.last_known_player_position = uptodate_last_known_playerpositon
		Villager.last_known_player_position = uptodate_last_known_playerpositon


func _on_PlayerGhostArea_body_entered(body):
	PlayerGhost.visible = false


func _on_PathUpdateTimer_timeout():
	pass # Replace with function body.
