"""
1. figure out which faction you are.

2. at intervals, pick one of your planets
	then create a NavTarget at another planet

3. time permitting, the paths could have sin functions

"""

extends Node

var Faction : int
var Difficulty : float
var win : bool = false

signal ships_requested(destinationPlanet)
signal faction_lost(faction)

# Called when the node enters the scene tree for the first time.
func _ready():
	Difficulty = float(1.0 + global.options["difficulty"]) # 1, 2, 3

func start(faction):
	
	$DecisionTimer.start()
	Faction = faction
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_random_planet(faction):
	return global.planet_container.get_random_planet(faction)
	

func plot_new_course():
	var factionToAttack : int
	
	if Difficulty > 2:
		if randf() < 0.6:
			factionToAttack = 0
		else:
			factionToAttack = global.PlayerFaction
	var originPlanet = get_random_planet(Faction)
	var destinationPlanet = get_random_planet(factionToAttack)
	# note: this will send ships to your own planets sometimes
	if originPlanet != destinationPlanet:
		return [originPlanet, destinationPlanet]

func spawn_fleet(courseArr):
	#print(courseArr)
	if courseArr == null or courseArr.size() == 0:
		return
	if courseArr[0] == null or courseArr[1] == null:
		return # hack to stop AI from spawning ships with no NavTarget
		
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
	#print("AI Faction == ", Faction)
	
	var planets = global.planet_container.get_children()
	var friendlyPlanets = []
	for planet in planets:
		if planet.Faction == Faction:
			friendlyPlanets.push_back(planet)
	#print("planets_remaining == ", friendlyPlanets.size())
	return friendlyPlanets.size()
	
	
func _on_DecisionTimer_timeout():
	if planets_remaining() > 0 and win == false:
		spawn_fleet(plot_new_course())
		$DecisionTimer.set_wait_time(rand_range(0.8, 5.0/(Difficulty)))
		$DecisionTimer.start()
	else:
		#print(self.name, " triggered _on_DecideionTimer_timeout" )
		connect("faction_lost", global.level, "_on_faction_lost")
		emit_signal("faction_lost", Faction)
		disconnect("faction_lost", global.level, "_on_faction_lost")
		
func _on_player_lost():
	win = true
	