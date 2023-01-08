extends Node

var isMuted = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setVolumeMaster(newVolume) -> void:
    ## 0-100
    #var bus_index = AudioServer.get_bus_index("Master")
    AudioServer.set_bus_volume_db(0, linear2db(newVolume))

func mute(toggle : bool):
    isMuted = toggle
    setVolumeMaster(1 * (0 if toggle else 1))