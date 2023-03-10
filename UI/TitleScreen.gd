extends Node

var mapPrefab = preload("res://Map.tscn")
var levelPrefab = preload("res://UI/LevelUI.tscn")

onready var mainMenu = $"%MainMenu"
onready var levelMenu = $"%LevelMenu"
onready var levelMenuLevels = $"%LevelMenuLevels"



func startGame(level: String):
    var map = mapPrefab.instance()
    get_tree().root.add_child(map)
    map.init(level)
    queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
    var map = mapPrefab.instance()
    $"%AudioBTN".pressed = Audio.isMuted
    self.add_child(map)
    map.init_titlescreen()
    initLevels()

func initLevels():
    for lvl in Constants.LEVELS.keys():
        print("initializing %s" % lvl)
        var lvlPanel = levelPrefab.instance()
        levelMenuLevels.add_child(lvlPanel)
        lvlPanel.selectMap = funcref(self, "startGame")
        lvlPanel.init(lvl, Constants.LEVELS[lvl]["info"]["title"], Constants.LEVELS[lvl]["info"]["description"])

func _on_PlayBtn_pressed():
    mainMenu.visible = false
    levelMenu.visible = true

func _on_EditBtn_pressed():
    var map = mapPrefab.instance()
    get_tree().root.add_child(map)
    map.init_leveleditor()
    queue_free()

func _on_SettingsBtn_pressed():
    print("settings")


func _on_AudioBTN_toggled(button_pressed:bool):
    print("toggled %s" % button_pressed)
    Audio.mute(button_pressed)
    $"%AudioBTN".text = "Audio OFF" if button_pressed else "Audio ON"
