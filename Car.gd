extends KinematicBody2D
var map
var sparkPrefab = preload("res://Assets/car/spark.tscn")

onready var sparks = $Particles2D


var elapsedTime = 0
var direction : int
var currentTile : Dictionary
var speed = Utils.rng.randf_range(1,2)
var velocity = Vector2()
var destination : Vector2
var nextDirection : int

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func place(initialTile : Vector2, dest: Vector2):
	var initialPos = Utils.tileToPos(initialTile)

	self.destination = dest
	currentTile = map.tiles[initialTile]

	$Sprite.modulate =  Color(randf(), randf(), randf())
	
	if currentTile["type"] == Constants.Tile.Road_X:
		self.direction = Constants.Direction.Left if initialPos.x > Utils.SCREEN_X_GRID / 2 else Constants.Direction.Right
		if self.direction == Constants.Direction.Right:
			## GOoing right
			position = Vector2(initialPos.x, initialPos.y + 12)
		else:
			## Going left
			position = Vector2(initialPos.x, initialPos.y + 4)
	elif currentTile["type"] == Constants.Tile.Road_Y:
		self.direction = Constants.Direction.Up if initialPos.y > Utils.SCREEN_Y_GRID / 2 else Constants.Direction.Down
		if self.direction == Constants.Direction.Up:
			## Going up:
			position = Vector2(initialPos.x + 12, initialPos.y)
		else:
			## Going down
			position = Vector2(initialPos.x + 4, initialPos.y)
	self.rotation = Constants.DirectionRotation[self.direction]
	nextDirection = self.direction
	velocity = Vector2(speed, 0).rotated(rotation)
		

func getPossibleNextDirection():
	#print("Possible next directions of type %s:" % Constants.Tile.keys() [map.tiles[Utils.getClosestTileToPos(position)]["type"]])
	var possibleNextTiles = map.getValidNearbyTiles(Utils.getClosestTileToPos(position), direction)
	if possibleNextTiles.size() < 1:
		return direction
	
	return possibleNextTiles[Utils.rng.randi() % possibleNextTiles.size()]["direction"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func hit(collision):
	#var newSparks = sparkPrefab.instance()
	#add_child(newSparks)
	sparks.position = collision.normal
	speed = -speed
	sparks.restart()
	sparks.emitting = true
	velocity = velocity.bounce(collision.normal) * 0.75 + collision.normal * 0.25


func _physics_process(delta):
	#print("%s (%s * %s = %s)" % [velocity, Vector2(speed, 0), rotation, Vector2(speed, 0).rotated(rotation)])
	elapsedTime += delta
	var currentTilePos = Utils.getClosestTileToPos(self.position)
	if currentTile["type"] in Constants.RoadTiles:
		velocity += velocity * delta * 1.1
	else:
		velocity -= velocity * delta
	velocity -= velocity * delta
	#velocity = velocity.rotated(rotation)
	velocity = velocity.rotated(velocity.angle_to(Constants.DirectionVector[nextDirection]) * delta * 10)


	if Utils.isOutOfBounds(currentTilePos):
		queue_free()
	else:
		if map.tiles.has(currentTilePos):
			var newTile = map.tiles[currentTilePos]

			if currentTile != newTile:
				currentTile = newTile
				nextDirection = getPossibleNextDirection()

				direction = nextDirection
				#rotation = nextDirection
	

	if currentTile["type"] in [Constants.Tile.Road_X, Constants.Tile.Road_Y]:
		var baseTile = Utils.getClosestTileToPos(position) * 16
		var leeway = 0.5
		if direction == Constants.Direction.Left:
			if abs(position.y - baseTile.y -  4) > leeway:
				velocity = velocity.rotated(-PI/2 * delta * ((baseTile.y + 4) - position.y))
				velocity -= velocity * delta * 0.5
		elif direction == Constants.Direction.Right:
			if abs(position.y - baseTile.y -  12) > leeway:
				velocity = velocity.rotated(PI/2 * delta * ((baseTile.y + 12) - position.y))
				velocity -= velocity * delta * 0.5
		elif direction == Constants.Direction.Down:
			if abs(position.x - baseTile.x -  4) > leeway:
				velocity = velocity.rotated(-PI/2 * delta * ((baseTile.x + 4) - position.x))
				velocity -= velocity * delta * 0.5
		elif direction == Constants.Direction.Up:
			if abs(position.x - baseTile.x -  12) > leeway:
				velocity = velocity.rotated(PI/2 * delta * ((baseTile.x + 12) - position.x))
				velocity -= velocity * delta * 0.5
	var collision = move_and_collide(velocity)
	if collision:
		#velocity = Vector2(0, 0).rotated(rotation)
		velocity = velocity.bounce(collision.normal)
		if collision.collider.has_method("hit"):
			collision.collider.hit(collision)
	self.rotation = velocity.angle()
	
	#velocity = move_and_slide(velocity)
