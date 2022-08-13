using Godot;
using System;
using Godot.Collections;

public class Room : Node2D {
	[Export] public Dictionary<string, bool> Openings = new Dictionary<string, bool>() {
		["NorthwestNorth"] = false,
		["North"] = false,
		["NortheastNorth"] = false,
		
		["NortheastEast"] = false,
		["East"] = false,
		["SoutheastEast"] = false,
		
		["SoutheastSouth"] = false,
		["South"] = false,
		["SouthwestSouth"] = false,
		
		["SouthwestWest"] = false,
		["West"] = false,
		["NorthwestWest"] = false
	};
	
	public Dictionary<string, string> Mapping = new Dictionary<string, string>() {
		["NorthwestNorth"] = "SouthwestSouth",
		["North"] = "South",
		["NortheastNorth"] = "SoutheastSouth",
		
		["NortheastEast"] = "NorthwestWest",
		["East"] = "West",
		["SoutheastEast"] = "SouthwestWest",
		
		["SoutheastSouth"] = "NortheastNorth",
		["South"] = "North",
		["SouthwestSouth"] = "NorthwestNorth",
		
		["SouthwestWest"] = "SoutheastEast",
		["West"] = "East",
		["NorthwestWest"] = "NortheastEast"
		
	};

	public bool GetConnection(string complementaryOpening) {
		return Openings[Mapping[complementaryOpening]];
	}
}
