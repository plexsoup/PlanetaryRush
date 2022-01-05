extends Node2D

# Declare member variables here. Examples:
var min_distance : float = 250
var DeploymentZone : Rect2



enum PlanetaryPatterns { SIN, CIRCLE, ELLIPSE, SPIRAL, GLOBS, RANDOM }

signal faction_lost(factionObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var AA = Vector2( -1 * global.screen_size )
	var BB = Vector2( 2 *global.screen_size )
	DeploymentZone = Rect2(AA, BB)
	global.planet_container = self # singleton, but it should be registered in Level, not global.
	
func start(factionObj):
	pass # have to wait for factions to be ready first.

func spawnPlanets(factionObj, totalNumPlanets):
	randomize()
	var startingPlanetSize : float = 1.5
	
	var p = PlanetaryPatterns
	var patterns = [p.SIN, p.RANDOM]
	var pattern = patterns[randi()%patterns.size()]

	for planetNum in range(totalNumPlanets):
		var randScale : float = rand_range(0.75, 1.5)
		var targetPos : Vector2 = get_target_pos(pattern, planetNum, totalNumPlanets)
		spawnPlanet(factionObj, startingPlanetSize * randScale, targetPos)


func get_target_pos(pattern, planetNum, totalNumPlanets):
	randomize()
	var targetPos = DeploymentZone.position
	var width = DeploymentZone.size.x
	var height = DeploymentZone.size.y
	
	if pattern == PlanetaryPatterns.SIN:
		targetPos.x += ( float(planetNum) / float(totalNumPlanets) * float(width) )
		if planetNum % 2 == 0:
			targetPos.y += ( sin(2.0 * PI * float(planetNum) / float(totalNumPlanets)) * float(height/2.0) + height/2)
		else:
			targetPos.y -= ( sin(2.0 * PI * float(planetNum) / float(totalNumPlanets)) * float(height/2.0) - height/2)

	elif pattern == PlanetaryPatterns.ELLIPSE:
		pass
	elif pattern == PlanetaryPatterns.CIRCLE:
		pass
	elif pattern == PlanetaryPatterns.SPIRAL:
		pass
	elif pattern == PlanetaryPatterns.GLOBS:
		pass
	elif pattern == PlanetaryPatterns.RANDOM:
		targetPos.x += rand_range(0, width)
		targetPos.y += rand_range(0, height)

	
	return targetPos
		
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawnPlanet(factionObj, planetSize, targetPos):
	var planetScene = load("res://Planets/Planet.tscn")
	var newPlanet = planetScene.instance()
	add_child(newPlanet)
	#newPlanet.call_deferred("start", factionObj, planetSize)
	newPlanet.start(factionObj, planetSize) # has to happen right away to build the factions' planet lists

	var safe_location_found : bool = false
	var i : int = 0

	while safe_location_found == false and i < 200:

		var jitterDist = 150
		var jitter = Vector2(rand_range(-jitterDist, jitterDist), rand_range(-jitterDist, jitterDist))
		newPlanet.set_global_position(targetPos + jitter)
		if not isColliding(newPlanet):
			safe_location_found = true
		i += 1
			
	
		
func isColliding(new_planet):	
	var myPos = new_planet.get_global_position()
	for planet in get_children():
		if planet != new_planet:
			var planetPos = planet.get_global_position()
			if myPos.distance_squared_to(planetPos) < min_distance * min_distance:
				# collision detected
				return true
	return false

func get_nearest_planet(pos):
	var closest = null
	var closest_dist_sq = 10000000
	for planet in self.get_children():
		var planetPos = planet.get_global_position()
		var dist_sq_to_planet = pos.distance_squared_to(planetPos)
		if dist_sq_to_planet < closest_dist_sq:
			closest_dist_sq = dist_sq_to_planet
			closest = planet
	return closest
	

func get_nearest_faction_planet(factionObj, pos):

	var closestPlanet = null
	var closest_dist_sq = 10000000
	for planet in self.get_children():
		if planet.FactionObj == factionObj:
			var planetPos = planet.get_global_position()
			var dist_sq_to_planet = pos.distance_squared_to(planetPos)
			if dist_sq_to_planet < closest_dist_sq:
				closest_dist_sq = dist_sq_to_planet
				closestPlanet = planet
	return closestPlanet
	
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
			return null
	else:
		returnPlanet = allPlanets[randi()%allPlanets.size()]
	
	return returnPlanet



