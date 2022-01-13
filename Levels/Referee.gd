extends Node
# monitor planet exchanges
# count number of planets
# count number of remaining factions
# declare loss or victory


# Declare member variables here. Examples:
var Level : Node2D = null
var Factions : Node2D
var Planets : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(levelObj, factionContainer, planetContainer):
	Level = levelObj
	Factions = factionContainer
	Planets = planetContainer
	$InspectionTimer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func check_win_conditions():
	pass
	

func _on_InspectionTimer_timeout():
	check_win_conditions()
