extends Node2D


# Declare member variables here. Examples:
var Number : int
export var IsLocalHumanPlayer : bool = false
export var IsNeutralFaction : bool = false
var fColor : Color
var CursorObj : Node2D


var CurrentPlanetList = []
#var CurrentShipList = [] 
var CurrentFleetList = [] # keep track so we can stay alive until the last fleet is gone

enum States { PAUSED, PLAYING, DEAD} # not really using PAUSED yet
var State = States.PAUSED

var Level : Node2D

signal faction_won(factionObj)
signal faction_lost(factionObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(number, myName, myColor, isLocalHuman, isNeutralFaction, levelObj):
	printerr("Faction.gd needs to get a reference to it's level object, so it knows who to signal")
	Level = levelObj
	Number = number
	name = myName
	fColor = myColor
	if isLocalHuman:
		IsLocalHumanPlayer = true
		global.PlayerFactionObj = self
			
	IsNeutralFaction = isNeutralFaction
	set_modulate(myColor)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func registerShip(shipObj):
#	CurrentShipList.push_back(shipObj)
#
#func deregisterShip(shipObj):
#	CurrentShipList.erase(shipObj)
#	if lose_conditions_met():
#		lose()

func registerFleet(fleetObj):
	CurrentFleetList.push_back(fleetObj)
	
func deregisterFleet(fleetObj):
	CurrentFleetList.erase(fleetObj)
	if lose_conditions_met():
		lose()

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

func die():
	print("Faction " + self.name + " is dead now.")
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
	printerr("Faction.gd deprecated function _win_conditions_met. It's not the faction's job to determine this.")
	# This can win too early because it 
	# doesn't account for ships in flight.

	# between you and the neutral faction, all planets are accounted for.
#	var win :bool = false
#	if IsNeutralFaction == true:
#		return false # no point winning if you're neutral
#	else: # actual player
#		var totalPlanets = global.planet_container.get_child_count()
#		var totalAlliedPlanets = CurrentPlanetList.size()
#		var neutralPlanets = countNeutralPlanets()
#
#		if totalAlliedPlanets + neutralPlanets == totalPlanets:
#			win = true
#		else:
#			win = false
#
#	return win

func win():
	printerr("Faction.gd deprecated function win(). It's no longer Faction's responsibility to declare winners.")
#		print("faction " + self.Name + " thinks it won the game")
#
#		connect("faction_won", global.Main.CurrentLevel, "_on_faction_won")
#		emit_signal("faction_won", self)
#		disconnect("faction_won", global.Main.CurrentLevel, "_on_faction_won")	

func lose_conditions_met():
	# no planets and no ships left
	var remainingPlanets = CurrentPlanetList.size()
	var remainingFleets = CurrentFleetList.size()
	if remainingPlanets == 0 and remainingFleets == 0:
		print(self.name + " says: Yep, no fleets or planets left. Quitting")
		return true
	else:
		return false

func lose():
	die() # just sets the state. Must come before the signal so Level can accurately look for a winner
	connect("faction_lost", Level, "_on_faction_lost")
	emit_signal("faction_lost", self)
	disconnect("faction_lost", Level, "_on_faction_lost")


#####################################################################
# "Public" functions

func IsAlive():
	if State == States.DEAD:
		return false
	else:
		return true

#####################################################################
# Incoming Signals
	
func _on_planet_switched_faction(planetObj, newFaction):
	#print("Faction.gd: _on_planet_switched_faction: " + planetObj.name + ": " + str(newFaction.Number))
	if CurrentPlanetList.has(planetObj) and newFaction == self:
		printerr("Faction trying to add a pre-owned planet to its planet list") #nothing to be done?
	elif CurrentPlanetList.has(planetObj) and newFaction != self:
		# lost a planet
		CurrentPlanetList.erase(planetObj)
	elif CurrentPlanetList.has(planetObj) == false:
		# gained a planet
		CurrentPlanetList.push_back(planetObj)
	
	if State == States.PLAYING:
		if lose_conditions_met():
			lose()

func _on_fleet_created(fleetObj):
	registerFleet(fleetObj)

func _on_fleet_destroyed(fleetObj):
	deregisterFleet(fleetObj)
	
#func _on_ship_created(shipObj):
#	registerShip(shipObj)
#
#func _on_ship_destroyed(shipObj):
#	deregisterShip(shipObj)
	
func _on_gameplay_started():
	State = States.PLAYING
	
func _on_gameplay_paused():
	State = States.PAUSED
	

