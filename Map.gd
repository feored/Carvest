extends Node2D


var carPrefab = preload("res://Car.tscn")

var tiles : Dictionary = {}
var SAVEPATH = "user://maps"
var SAVEPATH_SYSTEM = "res://maps"
var mapName = "last"


var money = 50
var metal = 0

var baseCarTimer = 1
var carTimer = baseCarTimer
var elapsedTime = carTimer
var spawnPoints = []

var holdingTile = false
var heldTile : Object
var clicking = false

onready var tileSelector = $"%TileSelect"
onready var tilesNode = $"%Tiles"
onready var moneyLabel = $"%Money"
onready var metalLabel = $"%Metal"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func updateMoney():
	moneyLabel.text = "$%s" % money

func updateMetal():
	metalLabel.text = "%s" % metal

func addMetal(amount: int):
	metal += amount
	updateMetal()
	
func init(levelName: String):
	set_process_input(true)
	# for _i in range(Utils.SCREEN_X/Utils.GRID_SIZE):
	# 	for _j in range(Utils.SCREEN_Y/Utils.GRID_SIZE):
	# 		placeTile(Tile.Grass, Vector2(_i,_j))
	var mapInfo = Constants.LEVELS[levelName]["info"]
	for tileType in Constants.tileTextures:
		tileSelector.add_icon_item(Constants.tileTextures[tileType],"", tileType)
	loadMap(Constants.LEVELS[levelName]["map"], false)
	getSpawnPoints()
	self.baseCarTimer = mapInfo["carTimer"]
	self.money = mapInfo["initialMoney"]
	self.metal = 0

func init_titlescreen():
	set_process_input(false)
	$UI.visible = false
	loadMap("title.map", false)
	getSpawnPoints()
	baseCarTimer = 2


func _process(delta):
	elapsedTime += delta
	if elapsedTime > carTimer && spawnPoints.size() > 0:
		elapsedTime = 0
		var car = carPrefab.instance()
		car.map = self
		var carTile = spawnPoints[Utils.rng.randi() % spawnPoints.size()]
		car.place(carTile, Vector2(32, 10))
		add_child(car)
		carTimer = Utils.rng.randfn(self.baseCarTimer)
	if holdingTile:
		heldTile.position = Utils.getClosestTilePosToPos(get_viewport().get_mouse_position())

func getSpawnPoints():
	for _j in range(Utils.SCREEN_Y_GRID):
		if tiles.has(Vector2(0, _j)) && tiles[Vector2(0, _j)]["type"] in [Constants.Tile.Road_X, Constants.Tile.Road_Y]:
			spawnPoints.push_back(Vector2(0,_j))
		if tiles.has(Vector2(Utils.SCREEN_X_GRID - 1, _j)) && tiles[Vector2(Utils.SCREEN_X_GRID - 1, _j)]["type"] in [Constants.Tile.Road_X, Constants.Tile.Road_Y]:
			spawnPoints.push_back(Vector2(Utils.SCREEN_X_GRID - 1,_j))
	for _i in range(1, Utils.SCREEN_X_GRID - 1):
		if tiles.has(Vector2(_i, 0)) && tiles[Vector2(_i, 0)] in [Constants.Tile.Road_X, Constants.Tile.Road_Y]:
			spawnPoints.push_back(Vector2(_i, 0))
		if tiles.has(Vector2(_i, Utils.SCREEN_Y_GRID - 1)) && tiles[Vector2(_i, Utils.SCREEN_Y_GRID - 1)]["type"] in [Constants.Tile.Road_X, Constants.Tile.Road_Y]:
			spawnPoints.push_back(Vector2(_i, Utils.SCREEN_Y_GRID - 1))
	print(spawnPoints)


func saveMap():
	var saveFilePath = "%s/%s.map" %  [SAVEPATH, mapName]# OS.get_unix_time()]
	var directory = Directory.new();
	if (!directory.dir_exists(SAVEPATH)):
		var err = directory.make_dir(SAVEPATH)
		if err != OK:
			print("Failed to create /%s/ directory to save maps into.", SAVEPATH)
			return
	var file = File.new()
	file.open(saveFilePath, File.WRITE)
	file.store_var(tiles)
	file.close()

func loadMap(mapName : String, user = true):
	var mapPath = "%s/%s" % [SAVEPATH if user else SAVEPATH_SYSTEM, mapName]
	var directory = Directory.new();
	if (!directory.dir_exists(SAVEPATH) || !directory.file_exists(mapPath)):
		print("Failed to find the save game %s that needs to be loaded." % mapPath)
		return

	var file = File.new()
	file.open(mapPath, File.READ)
	var map = file.get_var()

	## Load State
	for pos in map:
		placeTile(map[pos]["type"], pos, map[pos]["flip_h"], map[pos]["flip_v"])

	file.close()


func cleanMap():
	tiles.clear()
	for tile in tilesNode.get_children():
		tile.queue_free()
	for _i in range(Utils.SCREEN_X_GRID):
		for _j in range(Utils.SCREEN_Y_GRID):
			placeTile(Constants.Tile.Grass, Vector2(_i, _j))


func placeTile(tile : int, pos : Vector2, flipH : bool = false, flipV : bool = false):
	if(tiles.has(pos)):
		tiles[pos]["object"].queue_free()
		tiles[pos].clear()
	var newTile = Sprite.new()
	newTile.centered = false
	newTile.position = Utils.tileToPos(pos)
	newTile.texture =  Constants.tileTextures[tile]
	newTile.flip_h = flipH
	newTile.flip_v = flipV
	tilesNode.add_child(newTile)
	tiles[pos] = {"object": newTile, "type": tile, "flip_h": flipH, "flip_v": flipV}


func _on_SaveBtn_pressed():
	saveMap()

func _input(event):
	if holdingTile && (event.is_action_pressed("click") || clicking):
		clicking = true
		var tilePos : Vector2 = Utils.getClosestTilePosToPos(get_viewport().get_mouse_position()) / Utils.GRID_SIZE
		placeTile(tileSelector.selected, tilePos, heldTile.flip_h, heldTile.flip_v)
	if holdingTile && (event.is_action_released("click") || event.is_action_pressed("right_click") ):
		stopHolding()
	if holdingTile && event.is_action_pressed("rotate"):
		## 00 -> 01 -> 10 -> 11
		if !heldTile.flip_h:
			if !heldTile.flip_v:
				heldTile.flip_v = true
			else:
				heldTile.flip_v = false
				heldTile.flip_h = true
		else:
			if !heldTile.flip_v:
				heldTile.flip_v = true
			else:
				heldTile.flip_h = false
				heldTile.flip_v = false



func stopHolding():
	clicking = false
	heldTile.queue_free()
	holdingTile = false

func _on_LoadBtn_pressed():
	cleanMap()
	loadMap("%s.map" % mapName)


func _on_PlaceBtn_pressed():
	var newTile = Sprite.new()
	newTile.centered = false
	newTile.texture = Constants.tileTextures[tileSelector.selected]
	tilesNode.add_child(newTile)
	heldTile = newTile
	holdingTile = true


func _on_WipeBtn_pressed():
	cleanMap()


func _on_ArrowBtn_pressed():
    pass



func findPathToDestination(start: Vector2, direction: int, destination : Vector2) -> Array:
	##A* pathfinding
	var openTiles = {}

	var cameFrom = {}
	var costSoFar = {}
	
	var startTile = {
		"tile"  : start,
		"direction" : direction
	}

	cameFrom[startTile] = null
	costSoFar[startTile] = 0

	openTiles[startTile] = 0

	while openTiles.size() > 0:
		var examiningTile = openTiles.keys()[0]
		for tileData in openTiles.keys():
			if openTiles[tileData] < openTiles[examiningTile]:
				examiningTile = tileData

		openTiles.erase(examiningTile)

		if examiningTile["tile"] == destination:
			break

		for nextTile in Utils.getValidNearbyTiles(examiningTile):
			var newCost = costSoFar[examiningTile] + 1
			if (!(costSoFar.has(nextTile)) or newCost < costSoFar[nextTile]):
				costSoFar[nextTile] = newCost
				var f = newCost + Utils.getTileDistance(nextTile, destination)
				openTiles[nextTile] = f
				cameFrom[nextTile] = examiningTile

	
	## reconstruct path

	if ( !(cameFrom.has(destination))):
		return []
	var path = []
	var current = destination
	while current != self.currentTile:
		path.push_back(current)
		current = cameFrom[current]
	path.invert()

	return path


func getValidNearbyTiles(tile : Vector2, dir: int) -> Array:
	#print("Getting valid nearby tales of tile type %s (%s), flipped h: %s, flipped v : %s" % [Constants.Tile.keys() [tiles[tile]["type"]], tile, tiles[tile]["flip_h"], tiles[tile]["flip_v"]])
	var tileType = tiles[tile]["type"]
	var flipH = tiles[tile]["flip_h"]
	var flipV = tiles[tile]["flip_v"]
	var validTiles = []
	match tileType:
		Constants.Tile.Road_X :
			validTiles.push_back(
				{
					"tile": Utils.getTileInDirection(tile, dir),
					"direction" : dir
				}
			)
		Constants.Tile.Road_Y :
			validTiles.push_back(
				{
					"tile": Utils.getTileInDirection(tile, dir),
					"direction" : dir
				}
			)
		Constants.Tile.Cross:
			validTiles.push_back(
				{
					"tile": Utils.getTileInDirection(tile, dir),
					"direction" : dir
				}
			)

			validTiles.push_back(
				{
					"tile": Utils.getTileInDirection(tile, Utils.getRightTurnDirection(dir)),
					"direction" : Utils.getRightTurnDirection(dir)
				}
			)
		Constants.Tile.Tricross_X:
			if flipV:
				if dir == Constants.Direction.Down:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Utils.getRightTurnDirection(dir)),
							"direction" : Utils.getRightTurnDirection(dir)
						}
					)
				elif dir == Constants.Direction.Up:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)
				elif dir == Constants.Direction.Right:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)
				elif dir == Constants.Direction.Left:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)

					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Utils.getRightTurnDirection(dir)),
							"direction" : Utils.getRightTurnDirection(dir)
						}
					)
			else:
				if dir == Constants.Direction.Down:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)
				elif dir == Constants.Direction.Up:
					validTiles.push_back(
						{
							"tile": Utils.getRightTurnDirection(dir),
							"direction" : Utils.getRightTurnDirection(dir)
						}
					)
				elif dir == Constants.Direction.Right:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)

					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Utils.getRightTurnDirection(dir)),
							"direction" : Utils.getRightTurnDirection(dir)
						}
					)
				elif dir == Constants.Direction.Left:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)
		Constants.Tile.Tricross_Y:
			if flipH:
				if dir == Constants.Direction.Down:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)

					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Utils.getRightTurnDirection(dir)),
							"direction" : Utils.getRightTurnDirection(dir)
						}
					)
				elif dir == Constants.Direction.Up:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)
				elif dir == Constants.Direction.Right:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Utils.getRightTurnDirection(dir)),
							"direction" : Utils.getRightTurnDirection(dir)
						}
					)
				elif dir == Constants.Direction.Left:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)
			else:
				if dir == Constants.Direction.Down:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)
				elif dir == Constants.Direction.Up:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Utils.getRightTurnDirection(dir)),
							"direction" : Utils.getRightTurnDirection(dir)
						}
					)
				elif dir == Constants.Direction.Right:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, dir),
							"direction" : dir
						}
					)
				elif dir == Constants.Direction.Left:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Utils.getRightTurnDirection(dir)),
							"direction" : Utils.getRightTurnDirection(dir)
						}
					)
		Constants.Tile.Bend:
			if !flipH && !flipV:
				if dir == Constants.Direction.Left:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Constants.Direction.Down),
							"direction" : Constants.Direction.Down
						}
					)
				else:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Constants.Direction.Right),
							"direction" : Constants.Direction.Right
						}
					)
			elif flipH && !flipV:
				if dir == Constants.Direction.Right:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Constants.Direction.Down),
							"direction" : Constants.Direction.Down
						}
					)
				else:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Constants.Direction.Left),
							"direction" : Constants.Direction.Left
						}
					)
			elif !flipH && flipV:
				if dir == Constants.Direction.Down:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Constants.Direction.Right),
							"direction" : Constants.Direction.Right
						}
					)
				else:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Constants.Direction.Up),
							"direction" : Constants.Direction.Up
						}
					)
			else:
				if dir == Constants.Direction.Right:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Constants.Direction.Up),
							"direction" : Constants.Direction.Up
						}
					)
				else:
					validTiles.push_back(
						{
							"tile": Utils.getTileInDirection(tile, Constants.Direction.Left),
							"direction" : Constants.Direction.Left
						}
					) 
	return validTiles
		
