extends Node

var first = true

enum Tile {
	Grass,
	Fountain,
	Road_X,
	Road_Y,
	Cross,
	Bend,
	Tricross_X,
	Tricross_Y
}

var tileTextures = {
	Tile.Grass : load("res://Assets/tiles/grass.png"),
	Tile.Fountain : load("res://Assets/tiles/fountain.png"),
	Tile.Road_X: load("res://Assets/tiles/road_w.png"),
	Tile.Road_Y: load("res://Assets/tiles/road_v.png"),
	Tile.Cross: load("res://Assets/tiles/cross.png"),
	Tile.Bend : load("res://Assets/tiles/bend.png"),
	Tile.Tricross_X: load("res://Assets/tiles/tricross_w.png"),
	Tile.Tricross_Y: load("res://Assets/tiles/tricross_h.png")
}


enum Direction {
	Left,
	Right,
	Up,
	Down
}

enum Lane {
	Left,
	Right
}

var DirectionVector = {
	Direction.Left : Vector2(-1, 0),
	Direction.Right: Vector2(1, 0),
	Direction.Up: Vector2(0, -1),
	Direction.Down: Vector2(0, 1)
}

var RoadTiles = [
	Tile.Road_X,
	Tile.Road_Y,
	Tile.Cross,
	Tile.Bend,
	Tile.Tricross_X,
	Tile.Tricross_Y
]

var SolidTiles = [
	Tile.Fountain
]


var DirectionRotation = {
	Direction.Left : PI,
	Direction.Right: 0,
	Direction.Up: 3 * PI/2,
	Direction.Down: PI/2
}

enum Mod {
	Boost,
	Spikes,
	Portal_A,
	Portal_B,
	Wall
}

var modTextures = {
	Mod.Boost: load("res://Assets/mods/arrow.png"),
	Mod.Spikes: load("res://Assets/mods/spikes.png"),
	Mod.Portal_A: load("res://Assets/mods/portalA.tres"),
	Mod.Portal_B: load("res://Assets/mods/portalB.tres"),
}

var modCosts = {
	Mod.Boost: 50,
	Mod.Spikes: 25,
	Mod.Portal_A: 100,
	Mod.Portal_B:100,
	Mod.Wall:10
}

var LEVELS = {
	"SeaCity": {
		"info": {
			"title": "Sea City",
			"description":"""POP 87\n
			More of a rest stop than a town.""",
			"unlocked": true,
			"carTimer": 2,
			"initialMoney": 200,
			"goalMetal": 50,
			"timeAllowed": 60
		},
		"map" : "seacity.map"
	},
	"Highway": {
		"info": {
			"title": "Highway",
			"description":"""POP 0\n
			The highway. What else do you need to know?""",
			"unlocked": true,
			"carTimer": 1,
			"initialMoney": 500,
			"goalMetal": 250,
			"timeAllowed": 90
		},
		"map" : "highway.map"
	},
	"Swirl": {
		"info": {
			"title": "The Swirl",
			"description":"""POP 260\n
			The devil himself must have designed this town.""",
			"unlocked": true,
			"carTimer": 2,
			"initialMoney": 350,
			"goalMetal": 250,
			"timeAllowed": 90
		},
		"map" : "swirl.map"
	}
}
