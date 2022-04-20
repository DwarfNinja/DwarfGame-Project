extends Navigation2D

onready var PathNode = preload("res://Scenes/UI/Navigation/PathNode.tscn")
onready var Player = get_node("Walls/Player")
onready var PlayerGhost = get_node("Walls/PlayerGhost")

var current_playerposition
var uptodate_last_known_playerpositon

func _ready():
	Events.connect("RequestRoamCell", self, "_on_request_roamcell")
	Events.connect("RequestNavPath", self, "_on_request_navpath")
	Events.connect("UpdateLastKnownPlayerPosition", self, "_on_update_lastknown_playerposition")
	$Walls/PlayerGhost/PlayerGhostArea.connect("body_entered", self, "_on_PlayerGhostArea_body_entered")

#FIX: Make it unreliant on ("Walls/Player"), decoupling
func _process(_delta):
	if Player:
		current_playerposition = Player.get_global_position()
	
func _on_request_roamcell(Villager):
	var villager_spawn_position = $Areas.world_to_map(Villager.spawn_position)
	var villager_roam_destinations = []
	for cell in $Areas.get_used_cells():
		if cell.distance_to(villager_spawn_position) > 10:
			villager_roam_destinations.append($Areas.map_to_world(cell) + Vector2(7.99, 8.01)) #Bug in Nav2D where it rounds up ints?
				
	villager_roam_destinations.shuffle()
	var roam_cell = (villager_roam_destinations.pop_front())
#	$Indexes.set_cellv($Areas.world_to_map(roam_cell), 14) #DEBUG
	Villager.random_roamcell = roam_cell
	
func _on_request_navpath(Villager, target_cell):
	var path = get_simple_path(Villager.global_position, target_cell, false)
	Villager.path = PoolVector2Array(path)
	
func _on_update_lastknown_playerposition(received_playerposition, state):
	if uptodate_last_known_playerpositon == null:
		uptodate_last_known_playerpositon = received_playerposition
	else:
		if received_playerposition.distance_to(current_playerposition) < uptodate_last_known_playerpositon.distance_to(current_playerposition):
			uptodate_last_known_playerpositon = received_playerposition
	if state == 2: 
		PlayerGhost.global_position = uptodate_last_known_playerpositon
		PlayerGhost.visible = true
	else:
		PlayerGhost.visible = false
	
	for Villager in get_tree().get_nodes_in_group("Villager"):
#		if Villager.last_known_player_position != uptodate_last_known_playerpositon:
#			Villager.last_known_player_position = uptodate_last_known_playerpositon
		Villager.last_known_player_position = uptodate_last_known_playerpositon


func _on_PlayerGhostArea_body_entered(_body):
	PlayerGhost.visible = false

