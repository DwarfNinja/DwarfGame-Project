extends Node


const mapping = {
	"northwest_north": "southwest_south",
	"north": "south",
	"northeast_north": "southeast_south",
	
	"northeast_east": "northwest_west",
	"east": "west",
	"southeast_east": "southwest_west",
	
	"southeast_south": "northeast_north",
	"south": "north",
	"southwest_south": "northwest_north",
	
	"southwest_west": "southeast_east",
	"west": "east",
	"northwest_west": "northeast_east"
	}


export var openings = {
	"northwest_north": false,
	"north": false,
	"northeast_north": false,
	
	"northeast_east": false,
	"east": false,
	"southeast_east": false,
	
	"southeast_south": false,
	"south": false,
	"southwest_south": false,
	
	"southwest_west": false,
	"west": false,
	"northwest_west": false
	}

func get_connection(complementary_opening):
	return openings[mapping[complementary_opening]]
