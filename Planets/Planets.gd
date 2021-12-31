extends Node2D

# Declare member variables here. Examples:
var min_distance : float = 250

signal faction_lost(factionObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func start(factionObj):
	pass # have to wait for factions to be ready first.

func spawnPlanets(factionObj):
	randomize()
	var numPlanetsToSpawn = 1
	var startingPlanetSize : float = 1.5
	
	if factionObj.IsNeutralFaction:
		numPlanetsToSpawn = 8 + randi()%7
		startingPlanetSize = rand_range(0.8, 1.5)

	for i in range(numPlanetsToSpawn):
		
		spawnPlanet(factionObj, startingPlanetSize)
	global.planet_container = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawnPlanet(factionObj, size):
	var planetScene = load("res://Planets/Planet.tscn")
	var newPlanet = planetScene.instance()
	add_child(newPlanet)
	newPlanet.call_deferred("start", factionObj, size)


	var safe_location_found : bool = false
	var i : int = 0

	while safe_location_found == false and i < 100:
		
		newPlanet.set_global_position(Vector2(rand_range(-global.screen_size.x, global.screen_size.x), rand_range(-global.screen_size.y, global.screen_size.y)))
		if isColliding(newPlanet) == false:
			safe_location_found = true
		i += 1
			
	
		
func isColliding(new_planet):	
	var myPos = new_planet.get_global_position()
	for planet in get_children():
		if planet != new_planet:
			var planetPos = planet.get_global_position()
			if myPos.distance_squared_to(planetPos) < min_distance * min_distance:
				return true
	return false

func get_nearest_planet(pos):
	var closest = null
	var closest_dist_sq = 10000000
	for planet in global.planet_container.get_children():
		var planetPos = planet.get_global_position()
		var dist_sq_to_planet = pos.distance_squared_to(planetPos)
		if dist_sq_to_planet < closest_dist_sq:
			closest_dist_sq = dist_sq_to_planet
			closest = planet
	return closest
	

func get_nearest_faction_planet(factionObj, pos):

	var closest = null
	var closest_dist_sq = 10000000
	for planet in global.planet_container.get_children():
		if planet.FactionObj == factionObj:
			var planetPos = planet.get_global_position()
			var dist_sq_to_planet = pos.distance_squared_to(planetPos)
			if dist_sq_to_planet < closest_dist_sq:
				closest_dist_sq = dist_sq_to_planet
				closest = planet
	return closest
	
# refactor: should move this into FactionObj
func get_faction_planets(factionObj):
	var factionPlanets :Array = []
	for planet in get_children():
		if planet.FactionObj == factionObj:
			factionPlanets.push_back(planet)
	return factionPlanets

func get_random_planet(factionObj):
	var returnPlanet : StaticBody2D
	var factionPlanets = get_faction_planets(factionObj)
	var allPlanets = get_children()
	
	if factionObj != null:
		if factionPlanets.size() > 0:
			returnPlanet = factionPlanets[randi()%factionPlanets.size()]
		else: # someone lost the game
			printerr(self.name + ": random planet requested for faction with zero planets")
			returnPlanet = allPlanets[randi()%allPlanets.size()]
	else:
		returnPlanet = allPlanets[randi()%allPlanets.size()]
	
	return returnPlanet

func getRemainingPlanetsCount(factionObj):
	return get_child_count()

