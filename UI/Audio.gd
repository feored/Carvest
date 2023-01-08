extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setVolumeMaster(newVolume) -> void:
    ## Volume in decibel, on scale -60 -> 0
    var bus_index = AudioServer.get_bus_index("Master")
    AudioServer.set_bus_volume_db(bus_index, linear2db(newVolume))
