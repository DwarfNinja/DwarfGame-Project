extends Node2D

onready var NW_AREA = get_node("ProximityAreas/NorthWestArea2D")
onready var N_AREA = get_node("ProximityAreas/NorthArea2D")
onready var NE_AREA = get_node("ProximityAreas/NorthEastArea2D")
onready var E_AREA = get_node("ProximityAreas/EastArea2D")
onready var SE_AREA = get_node("ProximityAreas/SouthEastArea2D")
onready var S_AREA = get_node("ProximityAreas/SouthArea2D")
onready var SW_AREA = get_node("ProximityAreas/SouthWestArea2D")
onready var W_AREA = get_node("ProximityAreas/WestArea2D")

signal northwestArea2D_body_entered()
signal northarea2D_body_entered()
signal northeastArea2D_body_entered()
signal eastarea2D_body_entered()
signal southeastArea2D_body_entered()
signal southarea2D_body_entered()
signal southwestArea2D_body_entered()

var northwest_wall = false
var north_wall = false
var northeast_wall = false
var east_wall = false
var southeast_wall = false
var south_wall = false
var southwest_wall = false
var west_wall = false

var min_deg
var max_deg

var north_min_deg = 30
var north_max_deg = 145

var east_min_deg = 112.5
var east_max_deg = 250

var south_min_deg = 192.5
var south_max_deg = 347.5

var west_min_deg = 65
var west_max_deg = 285

func _ready():
	$NorthWestArea2D.connect("body_entered", self, "_on_NorthWestArea2D_body_entered")
	$NorthArea2D.connect("body_entered", self, "_on_NorthArea2D_body_entered")
	$NorthEastArea2D.connect("body_entered", self, "_on_NorthEastArea2D")
	$EastArea2D.connect("body_entered", self, "_on_EastArea2D")
	$SouthEastArea2D.connect("body_entered", self, "_on_SouthEastArea2D")
	$SouthArea2D.connect("body_entered", self, "_on_SouthArea2D")
	$SouthWestArea2D.connect("body_entered", self, "_on_SouthWestArea2D")
	$WestArea2D.connect("body_entered", self, "_on_WestArea2D")

const mapping = {
	"northwest": "southwest_south",
	"north": "south",
	"northeast": "southeast_south",
	
	"east": "west",
	
	"southeast": "northeast_north",
	"south": "north",
	"southwest": "northwest_north",
	
	"west": "east",
	}


var walls = {
	"northwest": false,
	"north": false,
	"northeast": false,
	
	"east": false,
	
	"southeast": false,
	"south": false,
	"southwest": false,
	
	"west": false,
	}



func _on_get_surrounding_walls():
	pass


func _on_NorthWestArea2D_body_entered(body):
	walls.northwest = true

func _on_NorthArea2D_body_entered(body):
	north_wall = true
	
func _on_NorthEastArea2D_body_entered(body):
	northeast_wall = true
	
func _on_EastArea2D_body_entered(body):
	east_wall = true
	
func _on_SouthEastArea2D_body_entered(body):
	southeast_wall = true

func _on_SouthArea2D_body_entered(body):
	south_wall = true
	
func _on_SouthWestArea2D_body_entered(body):
	southwest_wall = true

func _on_WestArea2D(body):
	west_wall = true
