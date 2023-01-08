extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var life = 10
var map:  Object

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func wallHit(vel):
	life -= Utils.getVectorHurt(vel)
	if life < 0:
		queue_free()
