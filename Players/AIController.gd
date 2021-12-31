"""
1. figure out which faction you are.

2. at intervals, pick one of your planets
	then create a NavTarget at another planet

3. time permitting, the paths could have sin functions

"""

extends Node2D

var FactionObj : Node2D
var Difficulty : float
var win : bool = false

enum States { SEEKING, DRAWING_PATH, WAITING }
var State = States.WAITING

var CurrentTargetPlanet = null # planet to send ships toward
var CurrentSourcePlanet = null # planet from which to grab ships

enum RouteTypes { STRAIGHT, CURVED, SINE }
var CurrentRouteType = RouteTypes.STRAIGHT

var PseudoMouseSpeed : float = 8.0 # just a guess

#signal ships_requested(destinationPlanet) # removed.. all the AI can do is click

signal faction_lost(factionObj)
signal click_mouse()
signal release_mouse()


# Called when the node enters the scene tree for the first time.
func _ready():
	Difficulty = float(1.0 + global.options["difficulty"]) # 1, 2, 3

	
func start(factionObj):
	# set up a delay interval so the AI can't make too many Actions per minute.
	restart_timer()
	FactionObj = factionObj
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var objective:Vector2 = get_global_position()
	if State == States.SEEKING:
		objective = CurrentSourcePlanet.get_global_position()
	elif State == States.DRAWING_PATH:
		objective = CurrentTargetPlanet.get_global_position()
		
	move_cursor_toward_objective(objective)
	execute_click_events(objective)
	
	$StateLabel.text = States.keys()[State]

func move_cursor_toward_objective(objective):
	var currentPos = get_parent().get_global_position()
	var newPos = currentPos + currentPos.direction_to(objective) * PseudoMouseSpeed * global.game_speed
	get_parent().set_global_position( newPos )
	
	
func execute_click_events(objective):
	var myPos = get_global_position()
	var acceptableDistanceSquared = 250.0
	var distSqToObj = myPos.distance_squared_to(objective)
	# if the cursor is close enough to the objective, send a mouse click or release event
	if distSqToObj < acceptableDistanceSquared:
		if State == States.SEEKING:
			# change the state and execute a click
			start_path()
		elif State == States.DRAWING_PATH:
			print("AIController is trying to end_path() now")
			end_path()
			
	
	
# refactor: could move this function into the factionObj
func get_random_planet(factionObj):
	var rndPlanet = global.planet_container.get_random_planet(factionObj)
	#print("found random planet: " + str(rndPlanet) + " from " + global.planet_container.name)
	return rndPlanet
	

func plot_new_course():
	var factionToAttack : Node2D
	
	var diceroll = randf()
	
	if randf() < 0.6:
		factionToAttack = global.NeutralFactionObj
	else:
		factionToAttack = global.PlayerFactionObj
	
	var originPlanet = get_random_planet(FactionObj)
	var destinationPlanet = get_random_planet(factionToAttack)
	# note: this will send ships to your own planets sometimes
	if originPlanet != destinationPlanet:
		CurrentTargetPlanet = destinationPlanet
		CurrentSourcePlanet = originPlanet
		State = States.SEEKING
	else:
		
		restart_timer()
		

func restart_timer():
	$DecisionTimer.set_wait_time(rand_range(2.0/Difficulty * global.game_speed, 5.0/Difficulty * global.game_speed))
	$DecisionTimer.start()

func start_path():
	# call this when the cursor gets close to the origin planet..
	
	connect("click_mouse", get_parent(), "_on_PlayerController_Clicked")
	emit_signal("click_mouse")
	disconnect("click_mouse", get_parent(), "_on_PlayerController_Clicked")
	State = States.DRAWING_PATH

func end_path():
	# call this while DRAWING and the cursor approaches the destination planet
	connect("release_mouse", get_parent(), "_on_PlayerController_Released")
	emit_signal("release_mouse")
	disconnect("release_mouse", get_parent(), "_on_PlayerController_Released")
	State = States.WAITING
	restart_timer()

func isStillDrawing():
	if State == States.DRAWING_PATH:
		return true
	else:
		return false



func planets_remaining():
	#print("AI Faction == ", Faction)
	
	var planets = global.planet_container.get_children()
	var friendlyPlanets = []
	for planet in planets:
		if planet.FactionObj == FactionObj:
			friendlyPlanets.push_back(planet)
	#print("planets_remaining == ", friendlyPlanets.size())
	return friendlyPlanets.size()
	
	
func _on_DecisionTimer_timeout():
	#print("AI Timer ding")
	if global.State != global.States.FIGHTING:
		#print("global State == " + global.States.keys()[global.State])
		restart_timer()
		return
	else:
		#print("global State == " + global.States.keys()[global.State])
		pass
	
	if FactionObj.getRemainingPlanetCount() > 0 and win == false:
		#print("Plotting New Course")
		plot_new_course()

	else:
		#print(self.name, " triggered _on_DecideionTimer_timeout" )
		connect("faction_lost", global.level, "_on_faction_lost")
		emit_signal("faction_lost", FactionObj)
		disconnect("faction_lost", global.level, "_on_faction_lost")
		
func _on_player_lost():
	win = true
	
