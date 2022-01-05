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

enum States { SEEKING, DRAWING_PATH, WAITING, DEAD }
var State = States.WAITING

var CurrentTargetPlanet = null # planet to send ships toward
var CurrentSourcePlanet = null # planet from which to grab ships

enum RouteTypes { STRAIGHT, CURVED, SINE }
var CurrentRouteType = RouteTypes.STRAIGHT

var PseudoMouseSpeed : float = 16.0 # just a guess

#signal ships_requested(destinationPlanet) # removed.. all the AI can do is click

#signal faction_lost(factionObj)
signal click_mouse()
signal release_mouse()


# Called when the node enters the scene tree for the first time.
func _ready():
	Difficulty = float(1.0 + global.options["difficulty"]) # 1, 2, 3

	
func start(factionObj):
	# set up a delay interval so the AI can't make too many Actions per minute.
	restart_timer()
	FactionObj = factionObj
	CurrentSourcePlanet = FactionObj.CurrentPlanetList[0]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var level = global.Main.CurrentLevel
	if level.State == level.States.PLAYING and State != States.DEAD:
		if not is_instance_valid(FactionObj) or FactionObj.getRemainingPlanetCount() == 0:
			return
		
		if is_instance_valid(CurrentSourcePlanet):
			var objectivePos = getObjectivePos(CurrentSourcePlanet)
			move_cursor_toward_objective(objectivePos)
			execute_click_events(objectivePos)
			
			$StateLabel.text = States.keys()[State]
		else:
			printerr("AIController.gd " + self.name + " has no CurrentSourcePlanet")

func getObjectivePos(sourcePlanet):
	if is_instance_valid(sourcePlanet):
		var objectivePos:Vector2 = get_global_position()
		if State == States.SEEKING:
			if sourcePlanet != null and is_instance_valid(sourcePlanet):
				objectivePos = sourcePlanet.get_global_position()
			else:
				printerr("AIController.gd has invalid source planet")
		elif State == States.DRAWING_PATH:
			if CurrentTargetPlanet == null:
				printerr("AI Controller in _process, has no CurrentPlanet to seek")
			else:
				objectivePos = CurrentTargetPlanet.get_global_position()
		return objectivePos
	else:
		return self.get_global_position() # might need a better escape than this

func move_cursor_toward_objective(objectivePos):
	var currentPos = get_parent().get_global_position()
	var newPos = currentPos + currentPos.direction_to(objectivePos) * PseudoMouseSpeed * global.game_speed
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
			end_path()


## refactor: could move this function into the factionObj
#func get_random_planet(factionObj):
#	var rndPlanet = global.planet_container.get_random_planet(factionObj)
#	#print("found random planet: " + str(rndPlanet) + " from " + global.planet_container.name)
#	return rndPlanet


func plot_new_course():
	var level = global.Main.CurrentLevel
	var factionToAttack : Node2D
	var enemyFactionsRemaining = level.getRemainingFactions()
	enemyFactionsRemaining.remove(enemyFactionsRemaining.find(FactionObj))

	if enemyFactionsRemaining.has(global.PlayerFactionObj):
		var diceroll = randf()
		if diceroll < 0.33:
			factionToAttack = global.PlayerFactionObj
		else:
			factionToAttack = enemyFactionsRemaining[randi()%enemyFactionsRemaining.size()]
	
	
	var originPlanet = level.PlanetContainer.get_random_planet(FactionObj)
	var destinationPlanet
	if randf() < 0.66:
		destinationPlanet = level.PlanetContainer.get_nearest_faction_planet(factionToAttack, self.get_global_position())
	else:
		destinationPlanet = level.PlanetContainer.get_random_planet(factionToAttack)

	# note: this will send ships to your own planets sometimes
	if originPlanet != destinationPlanet:
		CurrentTargetPlanet = destinationPlanet
		CurrentSourcePlanet = originPlanet
		State = States.SEEKING
	else:
		
		restart_timer()
		

func restart_timer():
	if global.game_speed > 0.0:
		$DecisionTimer.set_wait_time(rand_range(2.0/Difficulty / global.game_speed, 5.0/Difficulty / global.game_speed))
		$DecisionTimer.start()
	else:
		printerr("AIController needs a pause function in restart_timer")

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

	
func die():
	State = States.DEAD
	call_deferred("queue_free") # this is probably safe. no one should expect AI Controller to be around after death.
	# could probably even queue_free my parent. (Cursor), or send a signal to kill itself
	
	
func _on_DecisionTimer_timeout():
	if global.State != global.States.FIGHTING:
		restart_timer()
		return
	else: # paused or dead?
		# we might need a mechanism to recover from pause..
		pass
	
	if FactionObj.getRemainingPlanetCount() > 0 and State != States.DEAD:
		plot_new_course()

	else:
		die()
		# AI Controller is not notifying anyone that it quit. 
		# It's the faction's job to notify level when no planets or ships remain.
		

