extends Control


# Declare member variables here. Examples:
onready var FactionProgressContainer = $TopHUD/HBoxContainer
var Level : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(factionsList, levelObj): # called by Level.gd
	initializeFactionProgressBars(factionsList)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
		
func initializeFactionProgressBars(factionList):
	factionList.erase(global.NeutralFactionObj)
	for faction in factionList:
		spawnProgressIndicator(faction)



func spawnProgressIndicator(factionObj):
	var progressScene = load("res://GUI/HUD/FactionProgressIndicator.tscn")
	var progressNode = progressScene.instance()
	FactionProgressContainer.add_child(progressNode)
	progressNode.start(factionObj, Level)
