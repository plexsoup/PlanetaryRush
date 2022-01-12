extends Control


# Declare member variables here. Examples:
onready var FactionProgressContainer = $TopHUD/HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(levelObj, factionsList): # called by Level.gd
	initializeFactionProgressBars(levelObj, factionsList)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
		
func initializeFactionProgressBars(levelObj, factionsList):
	for faction in factionsList:
		spawnProgressIndicator(levelObj, faction)



func spawnProgressIndicator(levelObj, factionObj):
	var progressScene = load("res://GUI/HUD/FactionProgressIndicator.tscn")
	var progressNode = progressScene.instance()
	FactionProgressContainer.add_child(progressNode)
	progressNode.start(levelObj, factionObj)
