extends Node2D


var carPrefab = preload("res://Car.tscn")
var staticTilePrefab = preload("res://Assets/tiles/StaticTile.tscn")
var wallPrefab = preload("res://Assets/mods/Wall.tscn")


var tiles : Dictionary = {}
var mods : Dictionary = {}
var SAVEPATH = "user://maps"
var SAVEPATH_SYSTEM = "res://maps"
var mapName = "last"


var money : int = 50
var metal : float = 0

var baseCarTimer = 1
var carTimer = baseCarTimer
var elapsedTime = carTimer
var spawnPoints = []

var holdingTile = false
var heldTile : Object
var clicking = false

var modOffset = Vector2(4, 4)
var holdingMod = false
var heldMod : Object
var selectedMod : int

var goalMetal : float = 99999
var timeLeft : float = 99999


var editorMode = false

onready var gameUI = $"%GameMenu"
onready var editorUI = $"%EditorMenu"
onready var escMenu = $"%Menu"
onready var tileSelector = $"%TileSelect"
onready var tilesNode = $"%Tiles"
onready var moneyLabel = $"%Money"
onready var metalLabel = $"%Metal"
onready var timeVal = $"%TimeVal"

onready var costsBtns = {
	Constants.Mod.Boost : $"%ArrowBtn",
	Constants.Mod.Spikes : $"%SpikesBtn",
	Constants.Mod.Portal_A: $"%PortalA",
	Constants.Mod.Portal_B: $"%PortalB",
	Constants.Mod.Wall : $"%WallBtn"
}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func setupAudio():
	$"%AudioBtn".pressed = Audio.isMuted
	$"%AudioBtn".text = "Audio OFF" if Audio.isMuted else "Audio ON"
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
func updateMoney():
	moneyLabel.text = "$%s" % money

func updateMetal():
	metalLabel.text = "%s/%s" % [int(metal), int(goalMetal)]

func updateTime():
	timeVal.text = "%s" % int(timeLeft) 

func addMetal(amount: float):
	metal += amount
	updateMetal()
	print(metal)
	
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
	self.goalMetal = mapInfo["goalMetal"]
	self.timeLeft = mapInfo["timeAllowed"]
	updateMetal()
	updateMoney()
	setupAudio()
	if Constants.first:
		$"%Explanation".visible = true
		get_tree().paused = true

func init_custom(levelName: String):
	set_process_input(true)
	# for _i in range(Utils.SCREEN_X/Utils.GRID_SIZE):
	# 	for _j in range(Utils.SCREEN_Y/Utils.GRID_SIZE):
	# 		placeTile(Tile.Grass, Vector2(_i,_j))
	for tileType in Constants.tileTextures:
		tileSelector.add_icon_item(Constants.tileTextures[tileType],"", tileType)
	loadMap(levelName, true)
	getSpawnPoints()
	self.baseCarTimer = 1
	self.money = 9999
	self.metal = 0
	self.goalMetal = 9999
	self.timeLeft = 999
	updateMetal()
	updateMoney()
	setupAudio()
	if Constants.first:
		$"%Explanation".visible = true
		get_tree().paused = true

func removeExplanation():
	$"%Explanation".visible = false
	get_tree().paused = false
	Constants.first =  false

func init_leveleditor():
	editorMode = true
	set_process_input(true)
	for tileType in Constants.tileTextures:
		tileSelector.add_icon_item(Constants.tileTextures[tileType],"", tileType)
	# for _i in range(Utils.SCREEN_X/Utils.GRID_SIZE):
	# 	for _j in range(Utils.SCREEN_Y/Utils.GRID_SIZE):
	# 		placeTile(Tile.Grass, Vector2(_i,_j))
	#loadMap("%s.map" % mapName, true)
	loadMap("title.map", false)
	self.carTimer = 0
	self.baseCarTimer = 99999
	getSpawnPoints()
	
	editorUI.visible = true
	gameUI.visible = false
	setupAudio()

func init_titlescreen():
	set_process_input(false)
	$UI.visible = false
	loadMap("title.map", false)
	getSpawnPoints()
	baseCarTimer = 2

func checkCosts():
	for mod in costsBtns.keys():
		if money < Constants.modCosts[mod]:
			costsBtns[mod].disabled = true

func _process(delta):
	timeLeft -= delta
	updateTime()
	checkCosts()
	checkSuccess()
	elapsedTime += delta
	if elapsedTime > carTimer && spawnPoints.size() > 0:
		elapsedTime = 0
		var car = carPrefab.instance()
		car.map = self
		var carTile = spawnPoints[Utils.rng.randi() % spawnPoints.size()]
		car.place(carTile, Vector2(32, 10))
		add_child(car)
		carTimer = Utils.rng.randfn(self.baseCarTimer)
	if holdingMod:
		heldMod.position  = modOffset + Utils.getClosestTilePosToPos(get_viewport().get_mouse_position(), 8)
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
	print(mapPath)
	var directory = Directory.new();
	if !directory.dir_exists(SAVEPATH):
		directory.make_dir(SAVEPATH)
	if (!directory.file_exists(mapPath)):
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
	mods.clear()
	for tile in tilesNode.get_children():
		tile.queue_free()
	for _i in range(Utils.SCREEN_X_GRID):
		for _j in range(Utils.SCREEN_Y_GRID):
			placeTile(Constants.Tile.Grass, Vector2(_i, _j))


func placeMod(mod : int, pos : Vector2, rot: float):
	money -= Constants.modCosts[mod]
	updateMoney()
	if(mods.has(pos)):
		mods[pos]["object"].queue_free()
		mods[pos].clear()
	# if mod in Constants.SolidTiles:
	#     var newTile = staticTilePrefab.instance()
	#     newTile.position = Utils.tileToPos(pos)
	#     var sprite = newTile.get_node("Sprite")
	#     sprite.texture =  Constants.tileTextures[mod]
	#     sprite.flip_h = flipH
	#     sprite.flip_v = flipV
	#     tilesNode.add_child(newTile)
	#     tiles[pos] = {"object": newTile, "type": mod, "flip_h": flipH, "flip_v": flipV}
	# else:
	var newTile
	if mod == Constants.Mod.Wall:
		newTile = wallPrefab.instance()
		#newTile.map = self
		newTile.position = modOffset + 8*(pos)
		newTile.rotation = rot
		tilesNode.add_child(newTile)
	else:
		newTile = Sprite.new()
		newTile.centered = true
		newTile.position = modOffset + 8*(pos)
		newTile.texture =  Constants.modTextures[mod]
		newTile.rotation = rot
		tilesNode.add_child(newTile)
	mods[pos] = {"object": newTile, "type": mod, "direction" : Utils.getDirectionFromRotation(rot)}


func placeTile(tile : int, pos : Vector2, flipH : bool = false, flipV : bool = false):
	if(tiles.has(pos)):
		tiles[pos]["object"].queue_free()
		tiles[pos].clear()
	if tile in Constants.SolidTiles:
		var newTile = staticTilePrefab.instance()
		newTile.position = Utils.tileToPos(pos)
		var sprite = newTile.get_node("Sprite")
		sprite.texture =  Constants.tileTextures[tile]
		sprite.flip_h = flipH
		sprite.flip_v = flipV
		tilesNode.add_child(newTile)
		tiles[pos] = {"object": newTile, "type": tile, "flip_h": flipH, "flip_v": flipV}
	else:
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
	if (event.is_action_pressed("menu")):
		escMenu.visible = !escMenu.visible
		get_tree().paused = escMenu.visible
	if editorMode:
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
	else:
		if holdingMod && event.is_action_pressed("click"):
			var tilePos : Vector2 = Utils.getClosestTilePosToPos(get_viewport().get_mouse_position(), 8) / 8
			placeMod(selectedMod, tilePos, heldMod.rotation)
			stopHoldingMod()
		if holdingMod && event.is_action_pressed("right_click"):
			stopHoldingMod()
		if holdingMod && event.is_action_pressed("rotate"):
			## 00 -> 01 -> 10 -> 11
			# if !heldMod.flip_h:
			#     if !heldMod.flip_v:
			#         heldMod.flip_v = true
			#     else:
			#         heldMod.flip_v = false
			#         heldMod.flip_h = true
			# else:
			#     if !heldMod.flip_v:
			#         heldMod.flip_v = true
			#     else:
			#         heldMod.flip_h = false
			#         heldMod.flip_v = false
			if !(selectedMod in [Constants.Mod.Portal_A, Constants.Mod.Portal_B]):
				heldMod.rotation += PI/2


func stopHolding():
	clicking = false
	heldTile.queue_free()
	holdingTile = false

func stopHoldingMod():
	clicking = false
	heldMod.queue_free()
	holdingMod = false

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
		

func checkSuccess():
	if timeLeft < 0:
		print("FAIL")
		$"%GameOverMenu".visible = true
		get_tree().paused = true
		$"%Failure".visible = true
	elif metal >= goalMetal:
		print("SUCCESS")
		$"%GameOverMenu".visible = true
		get_tree().paused = true
		$"%Success".visible = true

func _on_AudioBtn_toggled(button_pressed:bool):
	Audio.mute(button_pressed)
	$"%AudioBtn".text = "Audio OFF" if button_pressed else "Audio ON"

func _on_MainMenuBtn_pressed():
	get_tree().paused = false
	var menu = load("res://UI/TitleScreen.tscn").instance()
	get_tree().root.add_child(menu)
	queue_free()


func _on_ContinueBtn_pressed():
	get_tree().paused = false
	escMenu.visible = false


func selectMod(newMod: int):
	if newMod == Constants.Mod.Wall:
		var newTile = wallPrefab.instance()
		selectedMod = newMod
		tilesNode.add_child(newTile)
		heldMod = newTile
		holdingMod = true
	else:
		var newTile = Sprite.new()
		newTile.centered = true
		selectedMod = newMod
		newTile.texture = Constants.modTextures[selectedMod]
		tilesNode.add_child(newTile)
		heldMod = newTile
		holdingMod = true

func _on_ArrowBtn_pressed():
	selectMod(Constants.Mod.Boost)

func _on_SpikesBtn_pressed():
	selectMod(Constants.Mod.Spikes)


func _on_PortalB_pressed():
	selectMod(Constants.Mod.Portal_B)

func _on_PortalA_pressed():
	selectMod(Constants.Mod.Portal_A)


func _on_WallBtn_pressed():
	selectMod(Constants.Mod.Wall)


func _on_GameOverMenuBtn_pressed():
	_on_MainMenuBtn_pressed()


func _on_OKExplanation_pressed():
	removeExplanation()


func _on_PlayBtn_pressed():
	saveMap()
	var map = load("res://Map.tscn").instance()
	get_tree().root.add_child(map)
	map.init_custom("last.map")
	queue_free()
