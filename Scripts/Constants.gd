extends Node


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

var DirectionRotation = {
    Direction.Left : PI,
    Direction.Right: 0,
    Direction.Up: 3 * PI/2,
    Direction.Down: PI/2
}

var LEVELS = {
    "SeaCity": {
        "info": {
            "title": "Sea City",
            "description":"""POP 87
            More of a rest stop than a town.""",
            "unlocked": true,
            "carTimer": 5,
            "initialMoney": 50
        },
        "map" : "seacity.map"
    }
}