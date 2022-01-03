extends Node2D


# Declare member variables here. Examples:
var Number : int
var IsLocalHumanPlayer : bool = false
var IsNeutralFaction : bool = false
var fColor : Color
var CursorObj : Node2D
var Name : String

var CurrentPlanetList = []
var CurrentShipList = [] # keep track so we can stay alive until the last ship is dead

enum States { PAUSED, PLAYING, DEAD} # not really using PAUSED yet
var State = States.PAUSED

onready var Level = get_parent()

signal faction_won(factionObj)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(number, myName, myColor, isLocalHuman, isNeutralFaction):
	Number = number
	Name = myName
	fColor = myColor
	IsLocalHumanPlayer = isLocalHuman
	IsNeutralFaction = isNeutralFaction
	set_modulate(myColor)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func RegisterShip(shipObj):
	CurrentShipList.push_back(shipObj)
	
func DeregisterShip(shipObj):
	var shipIndex = CurrentShipList.find(shipObj)
	if shipIndex != -1:
		CurrentShipList.remove(shipIndex)



func getRemainingPlanetCount():
	var remainingPlanetCount = CurrentPlanetList.size()
	return remainingPlanetCount



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

func resign():
	print("Faction " + self.Name + " is quitting now.")
	State = States.DEAD
	#call_deferred("queue_free")

func countNeutralPlanets():
	if is_instance_valid(global.NeutralFactionObj):
		var neutralPlanets = 0
		for planet in global.planet_container.get_children():
			if planet.FactionObj == global.NeutralFactionObj:
				neutralPlanets += 1
		return neutralPlanets
	else:
		return 0


func win_conditions_met():
	# This can win too early because it doesn't account for ships in flight.

	print("Testing Win Conditions")
	# between you and the neutral faction, all planets are accounted for.
	var win :bool = false
	if IsNeutralFaction == true:
		return false # no point winning if you're neutral
	else: # actual player
		print(self.Name)
		var totalPlanets = global.planet_container.get_child_count()
		var totalAlliedPlanets = CurrentPlanetList.size()
		var neutralPlanets = countNeutralPlanets()

		if totalAlliedPlanets + neutralPlanets == totalPlanets:
			win = true
		else:
			win = false
			
	return win

func win():
		print("faction " + self.Name + " thinks it won the game")
		
		connect("faction_won", global.Main.CurrentLevel, "_on_faction_won")
		emit_signal("faction_won", self)
		disconnect("faction_won", global.Main.CurrentLevel, "_on_faction_won")	

func lose_conditions_met():
	# no planets and no ships left
	var remainingPlanets = CurrentPlanetList.size()
	var remainingShips = CurrentShipList.size()
	if remainingPlanets == 0 and remainingShips == 0:
		print(self.name + " says: Yep, no ships left. Quitting")
		return true
	else:
		return false

func lose():
	resign()

	
func _on_planet_switched_faction(planetObj, newFaction):
	#print("Faction.gd: _on_planet_switched_faction: " + planetObj.name + ": " + str(newFaction.Number))
	if CurrentPlanetList.has(planetObj) and newFaction == self:
		printerr("Faction trying to add a pre-owned planet to its planet list") #nothing to be done?
	elif CurrentPlanetList.has(planetObj) and newFaction != self:
		# lost a planet
		CurrentPlanetList.remove(CurrentPlanetList.find(planetObj))
	elif CurrentPlanetList.has(planetObj) == false:
		# gained a planet
		CurrentPlanetList.push_back(planetObj)
	
	if State == States.PLAYING: # the faction thinks it's playing too fast.. on start?
		if win_conditions_met() == true:
			win()
		elif lose_conditions_met():
			lose()


func _on_ship_created(shipObj):
	RegisterShip(shipObj)
	
func _on_ship_destroyed(shipObj):
	DeregisterShip(shipObj)
	
func _on_gameplay_started():
	State = States.PLAYING
	
func _on_gameplay_paused():
	State = States.PAUSED
	

