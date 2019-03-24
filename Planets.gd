extends Node2D

# Declare member variables here. Examples:
var min_distance : float = 250

signal faction_lost(faction)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for i in range(10):
		spawnPlanet(0, rand_range(0.8, 1.2))
	global.planet_container = self
	spawnPlanet(1, 1.5)
	spawnPlanet(2, 1.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawnPlanet(faction, size):
	var planetScene = load("res://Planet.tscn")
	var newPlanet = planetScene.instance()
	add_child(newPlanet)
	newPlanet.start(faction, size)

		
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
	

func get_nearest_faction_planet(faction, pos):

	var closest = null
	var closest_dist_sq = 10000000
	for planet in global.planet_container.get_children():
		if planet.Faction == faction:
			var planetPos = planet.get_global_position()
			var dist_sq_to_planet = pos.distance_squared_to(planetPos)
			if dist_sq_to_planet < closest_dist_sq:
				closest_dist_sq = dist_sq_to_planet
				closest = planet
	return closest
	
func get_random_planet(faction):
	var planets = get_children()
	
	if faction != null:
		var factionPlanets = []
		for planet in planets:
			if planet.Faction == faction:
				factionPlanets.push_back(planet)
		if factionPlanets.size() > 0:
			return factionPlanets[randi()%factionPlanets.size()]
		else: # someone lost the game
			connect("faction_lost", global.Main, "_on_faction_lost")
			emit_signal("faction_lost", faction)
			disconnect("faction_lost", global.Main, "_on_faction_lost")
	else:
		return planets[randi()%planets.size()]
