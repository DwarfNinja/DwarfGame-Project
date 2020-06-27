extends Node

export (bool) var opening_north
export (bool) var opening_east
export (bool) var opening_south
export (bool) var opening_west

func get_room_data():
	var connect_north = false
	var connect_east = false
	var connect_south = false
	var connect_west = false
	
	var shape_openings = [opening_north, opening_east, opening_south, opening_west]
	var viable_connections = [connect_north, connect_east, connect_south, connect_west]
	
	if opening_north == true:
		connect_south = true
	if opening_east == true:
		connect_west = true
	if opening_south == true:
		connect_north = true
	if opening_west == true:
		connect_south = true
		
	return([shape_openings,viable_connections])
