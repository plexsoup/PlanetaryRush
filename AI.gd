"""
1. figure out which faction you are.

2. at intervals, pick one of your planets
	then create a NavTarget at another planet

3. time permitting, the paths could have sin functions

"""

extends Node

var Faction : int

signal ships_requested(destinationPlanet)
signal faction_lost(faction)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(faction):
	
	$DecisionTimer.start()
	Faction = faction
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_random_planet(faction):
	return global.planet_container.get_random_planet(faction)
	

func plot_new_course():
	var originPlanet = get_random_planet(Faction)
	var destinationPlanet = get_random_planet(null)
	# note: this will send ships to your own planets sometimes
	return [originPlanet, destinationPlanet]

func spawn_fleet(courseArr):
	# make a new path and give it 2 points?
	var originPlanet = courseArr[0]
	if originPlanet != null:
		var destinationPlanet = courseArr[1]
		connect("ships_requested", originPlanet, "_on_AI_requested_ships")
		emit_signal("ships_requested", destinationPlanet)
		disconnect("ships_requested", originPlanet, "_on_AI_requested_ships")
			
#	var fleetScene = load("res://Fleet.tscn")
#	var newFleet = fleetScene.instance()
#
func planets_remaining():
	var planets = global.planet_container.get_children()
	var friendlyPlanets = []
	for planet in planets:
		if planet.Faction == Faction:
			friendlyPlanets.push_back(planet)
	return friendlyPlanets.size()
	
	
func _on_DecisionTimer_timeout():
	if planets_remaining() > 0:
		spawn_fleet(plot_new_course())
		$DecisionTimer.set_wait_time(rand_range(0.8, 5.0))
		$DecisionTimer.start()
	else:
		connect("faction_lost", global.Main, "_on_faction_lost")
		emit_signal("faction_lost", Faction)
		disconnect("faction_lost", global.Main, "_on_faction_lost")
		
