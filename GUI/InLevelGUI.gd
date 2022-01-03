extends Control


# Declare member variables here. Examples:
onready var FactionProgressContainer = $TopHUD/HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(factionsList): # called by Level.gd
	initializeFactionProgressBars(factionsList)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.Ticks % 100 == 0:
		updateFactionProgressBars()
		
func initializeFactionProgressBars(factionList):
	for faction in factionList:
		spawnProgressIndicator(faction)

func updateFactionProgressBars():
	pass

func spawnProgressIndicator(factionObj):
	var progressScene = load("res://GUI/FactionProgressIndicator.tscn")
	var progressNode = progressScene.instance()
	FactionProgressContainer.add_child(progressNode)
	progressNode.start(factionObj)
