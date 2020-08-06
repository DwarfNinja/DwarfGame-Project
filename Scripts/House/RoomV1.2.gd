extends Node

export (bool) var opening_northwest_north
export (bool) var opening_north
export (bool) var opening_northeast_north
export (bool) var opening_northeast_east
export (bool) var opening_east
export (bool) var opening_southeast_east
export (bool) var opening_southeast_south
export (bool) var opening_south
export (bool) var opening_southwest_south
export (bool) var opening_southwest_west
export (bool) var opening_west
export (bool) var opening_northwest_west

var connect_northwest_north
var connect_north
var connect_northeast_north

var connect_northeast_east
var connect_east
var connect_southeast_east

var connect_southeast_south
var connect_south
var connect_southwest_south

var connect_southwest_west
var connect_west
var connect_northwest_west

func _ready():
	pass

func get_room_data():
	if opening_northwest_north == true:
		connect_southwest_south = true
	if opening_north == true:
		connect_south = true
	if opening_northeast_north:
		connect_southeast_south = true
		
	if opening_northeast_east == true:
		connect_northwest_west = true
	if opening_east == true:
		connect_west = true
	if opening_southeast_east == true:
		connect_southwest_west = true
		
	if opening_southeast_south == true:
		connect_northeast_north = true
	if opening_south == true:
		connect_north = true
	if opening_southwest_south == true:
		connect_northwest_north = true
		
	if opening_southwest_west == true:
		connect_southeast_east = true
	if opening_west == true:
		connect_east = true
	if opening_northwest_west == true:
		connect_northeast_east = true
	
	var shape_openings = [
		opening_northwest_north, opening_north, opening_northeast_north, 
	opening_northeast_east, opening_east, opening_southeast_east, 
	opening_southeast_south, opening_south, opening_southwest_south, 
	opening_southwest_west, opening_west, opening_northwest_west]
	
	var viable_connections = [
		connect_northwest_north, connect_north, connect_northeast_north, 
		connect_northeast_east, connect_east, connect_southeast_east, 
		connect_southeast_south, connect_south, connect_southwest_south, 
		connect_southwest_west, connect_west, connect_northwest_west]
	
	return([shape_openings,viable_connections])
