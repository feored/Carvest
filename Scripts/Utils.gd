extends Node

const GRID_SIZE = 16

const SCREEN_X_GRID = 32
const SCREEN_Y_GRID = 18

const SCREEN_X = 16*32
const SCREEN_Y = 16*18

var rng = RandomNumberGenerator.new()


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func tileToPos(tile:  Vector2) -> Vector2:
    return GRID_SIZE * tile

func centeredTileToPos(tile:  Vector2) -> Vector2:
    return GRID_SIZE * tile + Vector2(GRID_SIZE/2, GRID_SIZE/2)

func modTileToPos(tile:  Vector2) -> Vector2:
    return 8 * tile

func getVectorHurt(vel : Vector2):
    return (abs(vel.x) + abs(vel.y))

func getTileNeighbors(tile : Vector2) -> Array:
    var neighbors = []
    for vec in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
        neighbors.push_back(tile+vec)
    return neighbors

func getClosestTilePosToPos(pos : Vector2, grid_size : int = GRID_SIZE) -> Vector2:
    var rest_x = (int(pos.x) / grid_size) * grid_size
    var rest_y = (int(pos.y) / grid_size) * grid_size
    return Vector2(rest_x, rest_y)

func getClosestTileToPos(pos : Vector2) -> Vector2:
    var rest_x = (int(pos.x) / GRID_SIZE)
    var rest_y = (int(pos.y) / GRID_SIZE)
    return Vector2(rest_x, rest_y)

func getTileInDirection(tile : Vector2, dir : int) -> Vector2:
    return tile + Constants.DirectionVector[dir]

func getRightTurnDirection(dir : int) -> int:
    match dir:
        Constants.Direction.Left:
            return Constants.Direction.Up
        Constants.Direction.Up:
            return Constants.Direction.Right
        Constants.Direction.Right:
            return Constants.Direction.Down
        Constants.Direction.Down:
            return Constants.Direction.Left
    return dir

static func getTileDistance(tile : Vector2, secondTile : Vector2) -> float:
    return abs(secondTile.x - tile.x) + abs(secondTile.y - tile.y)

# Called when the node enters the scene tree for the first time.
func _ready():
    rng.randomize()

func isOutOfBounds(tile : Vector2) -> bool:
    return tile.x < 0 || tile.x > SCREEN_X_GRID || tile.y < 0 || tile.y > SCREEN_Y_GRID


func getDirectionFromRotation(rot : float) -> int:
    var selectedDirection = 0
    for dir in Constants.DirectionRotation.keys():
        if is_equal_approx(fposmod(rot, 2*PI), Constants.DirectionRotation[dir]):
            selectedDirection = dir
            break
    return selectedDirection

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
