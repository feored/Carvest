extends PanelContainer

onready var btn = $VBoxContainer/Button
onready var desc = $VBoxContainer/PanelContainer/Label

var selectMap : Object
var id

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(mapId: String, title : String, description: String):
	self.id = mapId
	btn.text = title
	desc.text = description

func _on_Button_pressed():
	selectMap.call_func(id)
