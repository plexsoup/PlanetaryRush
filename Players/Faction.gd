extends Node2D


# Declare member variables here. Examples:
var Number : int
var IsLocalHumanPlayer : bool = false
var IsNeutralFaction : bool = false
var fColor : Color
var CursorObj : Node2D
onready var Level = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(number, myColor, isLocalHuman, isNeutralFaction):
	Number = number
	fColor = myColor
	IsLocalHumanPlayer = isLocalHuman
	IsNeutralFaction = isNeutralFaction
	set_modulate(myColor)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# factions could probably keep better track of their own planets?
func getRemainingPlanetCount():
	return global.level.PlanetContainer.getRemainingPlanetsCount(self)
	
