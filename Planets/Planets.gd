extends Node2D

# Declare member variables here. Examples:
var min_distance : float = 325
var DeploymentZone : Rect2



enum PlanetaryPatterns { SIN, CIRCLE, ELLIPSE, SPIRAL, GLOBS, RANDOM }

signal faction_lost(factionObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var AA = Vector2( -1.5 * global.screen_size )
	var BB = Vector2( 3.0 * global.screen_size )
	DeploymentZone = Rect2(AA, BB)
	global.planet_container = self # singleton, but it should be registered in Level, not global.
	
func start(factionObj):
	pass # have to wait for factions to be ready first.

func spawnPlanets(factionObj, totalNumPlanets, levelObj):
	randomize()
	var startingPlanetSize : float = 1.5
	
	var p = PlanetaryPatterns
	var patterns = [p.SIN, p.RANDOM, p.GLOBS]
	
	var pattern = patterns[randi()%patterns.size()]

	for planetNum in range(totalNumPlanets):
		var randScale : float = rand_range(0.75, 1.5)
		var targetPos : Vector2 = get_target_pos(pattern, planetNum, totalNumPlanets)
		
		spawnPlanet(factionObj, startingPlanetSize * randScale, targetPos, levelObj)


func get_target_pos(pattern, planetNum, totalNumPlanets):
	# must return a single Vector2 position
	randomize()

	var targetPos = DeploymentZone.position # the position to return

	var width = DeploymentZone.size.x
	var height = DeploymentZone.size.y
	var deploymentZoneCenter = DeploymentZone.position + (DeploymentZone.size/2)
	
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
		targetPos = deploymentZoneCenter
		# choose 2 to 5 locations and cluster around them
		var numFoci = 3 # can't be random, because it has to be consistent for each planet
		var fociLocations : PoolVector2Array = []
		for fociNum in range(numFoci):
			var currentFociLocation = deploymentZoneCenter
			#var currentFociLocation = global.camera.get_camera_screen_center() # could also work.
			currentFociLocation += Vector2.RIGHT.rotated(2*PI * fociNum / numFoci) * (DeploymentZone.size.x/3)
			fociLocations.push_back(currentFociLocation)

		# grab a random glob focus and spawn the planet nearby
		# random means they may not be evenly distributed
		targetPos += utils.GetRandElement(fociLocations)
		var spread = DeploymentZone.size.x / 4
		targetPos.x += rand_range(-spread, spread)
		targetPos.y += rand_range(-spread, spread)
			
			
	elif pattern == PlanetaryPatterns.RANDOM:
		targetPos.x += rand_range(0, width)
		targetPos.y += rand_range(0, height)

	
	return targetPos
		
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func importPlanets():
	# if the level designer handcrafted a level, it'll have planets already in place (from the inspector / 2D editor)
	# we need to absorb / intake those planets so the game knows about them.
	if get_child_count() > 0:
		for bespokePlanet in get_children():
		#	bespokePlanet.start(factionObj, planetSize, levelObj)
			printerr("Planets.gd: importPlanets. Needs development. Or can this be handled by Level.gd?")
			
func spawnPlanet(factionObj, planetSize, targetPos, levelObj):
	var planetScene = load("res://Planets/Planet.tscn")
	var newPlanet = planetScene.instance()
	add_child(newPlanet)
	#newPlanet.call_deferred("start", factionObj, planetSize)


	var safe_location_found : bool = false
	var i : int = 0

	while not safe_location_found and i < 200:

		var jitterDist = 150
		var jitter = Vector2(rand_range(-jitterDist, jitterDist), rand_range(-jitterDist, jitterDist))
		newPlanet.set_global_position(targetPos + jitter)
		if not isColliding(newPlanet):
			safe_location_found = true
		i += 1
		if i > 1 and i % 50 == 0:
			print("newPlanet " + newPlanet.name + " still looking for safe space after " + str(i) + " attempts")
	if not safe_location_found:
		# kill it. If you can't find a non-colliding space after 200 attempts, just die.
		newPlanet.queue_free()
	else:
		newPlanet.start(factionObj, planetSize, levelObj) # has to happen right away to build the factions' planet lists	

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
	var closest_dist_sq = 10000000000
	var planets = get_faction_planets(factionObj)
	if planets.size() == 0:
		printerr("someone requested a planet for a faction with none.")
		return null
	for planet in planets:
		var planetPos = planet.get_global_position()
		var dist_sq_to_planet = pos.distance_squared_to(planetPos)
		if dist_sq_to_planet < closest_dist_sq:
			closest_dist_sq = dist_sq_to_planet
			closestPlanet = planet
	return closestPlanet
	
func get_nearest_enemy_planet(factionObj, pos):
	var closestPlanet = null
	var closest_dist_sq = 10000000000
	var planets = get_enemy_planets(factionObj)
	if planets.size() == 0:
		printerr("someone requested a planet for a faction with none.")
		return null
	for planet in planets:
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

func get_enemy_planets(enemyFactionObj):
	var enemyFactionPlanets :Array = []
	for planet in get_children():
		if planet.FactionObj != enemyFactionObj:
			enemyFactionPlanets.push_back(planet)
	return enemyFactionPlanets
	



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

func get_lowest_population_adversary(factionObj):
	var planets = get_children()
	var enemyPlanets = []
	var lowestPopulation = 100
	var lowestPopPlanet
	for planet in planets:
		if planet.FactionObj != factionObj:
			if planet.get_population() < lowestPopulation:
				lowestPopPlanet = planet
				lowestPopulation = planet.get_population()
	return lowestPopPlanet
	
func get_largest_enemy_planet(factionObj):
	var largestSize = 0.0
	var largestPlanet = null
	for planet in get_enemy_planets(factionObj):
		if planet.Size > largestSize:
			largestSize = planet.Size
			largestPlanet = planet
		if planet.Size == largestSize:
			if randf() < 0.5:
				largestPlanet = planet
	if largestPlanet != null:
		return largestPlanet


