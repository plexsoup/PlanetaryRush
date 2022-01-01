extends Node2D


# Declare member variables here. Examples:
var Number : int
var IsLocalHumanPlayer : bool = false
var IsNeutralFaction : bool = false
var fColor : Color
var CursorObj : Node2D

var CurrentPlanetList = []

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

func get_nearest_planet(pos):
	var closestPlanet = null
	var closest_dist_sq = 10000000
	for planet in CurrentPlanetList:
		var planetPos = planet.get_global_position()
		var dist_sq_to_planet = pos.distance_squared_to(planetPos)
		if dist_sq_to_planet < closest_dist_sq:
			closest_dist_sq = dist_sq_to_planet
			closestPlanet = planet
	return closestPlanet


func _on_planet_switched_faction(planetObj, newFaction):
	if CurrentPlanetList.has(planetObj) and newFaction == self:
		printerr("Faction trying to add a pre-owned planet to its planet list") #nothing to be done?
	elif CurrentPlanetList.has(planetObj) and newFaction != self:
		# lost a planet
		CurrentPlanetList.remove(CurrentPlanetList.find(planetObj))
	elif CurrentPlanetList.has(planetObj) == false:
		# gained a planet
		CurrentPlanetList.push_back(planetObj)
		

