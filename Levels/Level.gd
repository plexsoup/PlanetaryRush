extends Node2D

# might not need these. but they could help with scene navigation
export var NextSceneName : String
export var PreviousSceneName : String

#export var IsCurrent : bool = false
#export var Bespoke : bool = false # bespoke levels are handcrafted in the Godot 2D editor. Useful for campaign
export var RequireNeutralCapture : bool = false

export var DesiredNumPlanets : int = 15
export var DesiredNumFactions : int = 4
var NumPlanets : int = 0
var NumFactions : int = 0


onready var FleetContainer : Node2D = $Fleets
onready var BulletContainer : Node2D = $Bullets
onready var PlanetContainer : Node2D = $Planets
onready var FactionContainer : Node2D = $Factions
onready var PathContainer : Node2D = $Paths
#onready var CursorsContainer : Node2D = $Cursors

var PlayerFactionObj : Node2D

var Winning_faction

enum States { INITIALIZING, PLAYING, PAUSED, CELEBRATING, LAMENTING }
var State = States.INITIALIZING

# Note: this enum exists in two places. Make sure they don't get out of sync.
# Level and Planets objects both have a list of patterns
enum PlanetaryPatterns { RANDOM, SIN, CIRCLE, ELLIPSE, SPIRAL, GLOBS, SCATTER, BESPOKE }
export (PlanetaryPatterns) var Pattern


signal level_completed(factionObj)
signal finished()

#signal player_lost()
signal set_initial_faction(factionObj)
signal gameplay_started()

var PathFollowScene = preload("res://Paths/FleetPath.tscn")

func _ready():
	#call_deferred("start")
	# this is causing a problem. The AI starts before the player has clicked out of the menu
	pass
	#start()

func start(blueprintContainer : Node2D = null, callbackObj = get_parent(), desiredNumPlanets = null, desiredNumFactions = null):
	printerr("Level.gd bugs:")
	printerr("restart() fails to clean up properly")
	printerr("Quick campaign shows too many planets")

	call_deferred("delayedStart", [blueprintContainer, callbackObj, desiredNumPlanets, desiredNumFactions])




func delayedStart(blueprintContainer : Node2D = null, callbackObj = get_parent(), desiredNumPlanets = null, desiredNumFactions = null):


	#Note: since we're now spawning levels dynamically, we should add numplanets and numfactions to the start function (pseudo constructor)
	
	global.BulletContainer = $Bullets # why? Who uses this? Need to refactor weapons.gd
	printerr("Level.gd should not require registering a BulletContainer with global.")

	if desiredNumFactions != null:
		DesiredNumFactions = desiredNumFactions
	if desiredNumPlanets != null:
		DesiredNumPlanets = desiredNumPlanets

	
	# spawn a bunch of neutral planets, then change NumFactions to their unique faction.
	if not is_instance_valid(blueprintContainer):
		NumPlanets = DesiredNumPlanets
		NumFactions = DesiredNumFactions
		spawn_factions(DesiredNumFactions)  # produces factionObj's in FactionContainer
		spawn_planets(NumPlanets)
		for faction in FactionContainer.get_children():
			var randomPlanet = PlanetContainer.get_random_neutral_planet()
			if is_instance_valid(randomPlanet):
				randomPlanet.switch_faction(self, faction)
				randomPlanet.set_initial_population(4.0)
	else:
		build_level_from_blueprint(blueprintContainer)

	spawn_in_level_GUI()
	hide_end_scenes()
	initializeCamera()
	
	$Referee.start(self, FactionContainer, PlanetContainer, PlayerFactionObj)
	State = States.PLAYING

func hide_end_scenes():
	$Foreground/WinScreen.set_visible(false)
	$Foreground/LoseScreen.set_visible(false)
	$Foreground/PauseMenu.set_visible(false)
	

func initializeCamera():
	$ActionCamera._set_current(true)
	$ActionCamera.start(self, PlanetContainer)
	
func resetCamera():
	$ActionCamera.resetToOrigin()
	
func spawn_in_level_GUI():
	# unfortunately, the in-level gui has to be in a CanvasLayer, but they can't be hidden, so you have to hide the gui in the inspector
	var numFactions = DesiredNumFactions # refactor: this shouldn't be in Global anymore.
	var factions = getRemainingFactions()
	
	$Foreground/InLevelGUI.show()
	$Foreground/InLevelGUI.start(self, factions)
	


func spawn_planets(numPlanets):
	var p = PlanetaryPatterns
	if Pattern == null or Pattern == p.RANDOM:
		# wasn't set by the level designer, so choose one at random
		var patterns = [p.SIN, p.SCATTER, p.GLOBS]
		Pattern = patterns[randi()%patterns.size()]
	if Pattern != p.BESPOKE and numPlanets == 0:
		numPlanets = int(rand_range(10,20))
	PlanetContainer.spawnPlanets(self, NumPlanets, Pattern) # make sure this happens after factions are created

func spawn_factions(numFactions):
	print("Level.gd: spawning " + str(numFactions) + " Factions")
	
	for factionNum in range(numFactions):
		var isHuman = false
		
		if factionNum == global.PlayerFactionNum:
			isHuman = true
		var newFaction = spawn_faction(factionNum, global.FactionColors[factionNum], isHuman)
		if isHuman == true:
			PlayerFactionObj = newFaction

		print("spawning faction: " + str(factionNum))

func spawn_faction(factionNum, color, isHuman):
	var factionScene = load("res://Players/Faction.tscn")
	var factionNode : Node2D
	var factionName : String
	
	if isHuman:
		factionName = "Player 1"
	else:
		factionName = "AI " + str(factionNum)
	
	factionNode = factionScene.instance()
	$Factions.add_child(factionNode)
	factionNode.start(self, factionNum, factionName, color, isHuman)

	return factionNode


	
func spawn_cursor(factionObj): # this could probably be moved into Faction
	
	# each cursor acts as a player controller, to receive input and draw paths
	var cursorScene = load("res://Players/Cursor.tscn")
	var cursorNode = cursorScene.instance()
	#cursorNode.set_global_position(Vector2(1,1))
	$Cursors.add_child(cursorNode)
	cursorNode.start(factionObj, factionObj.IsLocalHumanPlayer, self)
	factionObj.CursorObj = cursorNode

func spawn_path(planet, factionObj, cursorObj):
	
	var pathFollowNode = PathFollowScene.instance()
	pathFollowNode.set_global_position(planet.get_global_position())
	PathContainer.add_child(pathFollowNode)
	pathFollowNode.start(planet, factionObj, cursorObj, self)

func build_level_from_blueprint(blueprintContainer):
	DesiredNumFactions = 0
	DesiredNumPlanets = 0
	
	# look at the blueprint and identify existing planets, factions, etc.
	# make sure they get catalogued and initialized correctly
	print("Level.gd is identifying objects placed manually in the level designer.")
	# enumerate all the planets in the blueprint node
	# then spawn factions accordingly
	# then move the planets into the PlanetContainer
	
	#NumFactions = blueprintContainer.NumFactions
	
	var factionNums = []
	var planetsInLevel = blueprintContainer.get_children()
	for planet in planetsInLevel:
		if not factionNums.has(planet.FactionNum):
			factionNums.push_back(planet.FactionNum)
	
	factionNums.erase(-1) # get rid of neutral faction
	for factionNum in factionNums:
		var isHuman
		if factionNum == 0:
			isHuman = true
		else:
			isHuman = false
		var newFaction = spawn_faction(factionNum, global.FactionColors[factionNum], isHuman)
		if isHuman:
			PlayerFactionObj = newFaction

	for templatePlanet in planetsInLevel:
		var newPlanet = PlanetContainer.spawnPlanet(self, templatePlanet.Size, templatePlanet.get_global_position())
		if is_instance_valid(newPlanet):
			newPlanet.start(self, templatePlanet.Size)
			newPlanet.switch_faction(self, templatePlanet.FactionNum)
			newPlanet.set_initial_population(templatePlanet.Size)
			templatePlanet.hide()

	blueprintContainer.hide() # why isn't this working?

	var numPlanets = PlanetContainer.get_planet_count()


func remove_entities():
	
	var containers = [PlanetContainer, FleetContainer, PathContainer, FactionContainer]
	for container in containers:
		print("Level.gd remove_entities() clearing " + container.name)
		for entity in container.get_children():
			print("\t - clearing " + entity.name)
			if entity.has_method("end"):
				entity.end()
			else:
				entity.call_deferred("queue_free")
	
func toggle_soft_pause():
	# refactor: this is temporary. The functionality should live here, not in global.
	global.toggle_soft_pause()
	
func end():
	$ActionCamera._set_current(false)
	$Foreground/InLevelGUI.end()
	remove_entities()
	emit_signal("finished", self) # to whoever connected it on level spawn. Presumably Main.gd
	call_deferred("queue_free")

func restart():
	$Foreground/InLevelGUI.end()
	remove_entities()
	start()

func count_player_planets():
	var count = 0
	for planet in $Planets.get_children():
		if planet.FactionObj.IsLocalHumanPlayer:
			count += 1
	return count

func get_referee():
	return $Referee
	
	
func get_paths_to(planet):
	var pathsToPlanet : Array = []
	for path in PathContainer.get_children():
		if path.DestinationPlanet == planet:
			pathsToPlanet.push_back(path)
	return pathsToPlanet
			
	
	
func start_celebration():
	# lock out player inputs?
	# show some fireworks or do a little dance
	if State == States.CELEBRATING:
		return
	
	else:
		State = States.CELEBRATING
			 
		$CelebrationTimer.start()
		
		for planet in PlanetContainer.get_children():
			if planet.has_method("celebrate"):
				planet.celebrate()

func start_lamentation():
	# Player lost. Start a timer and play some animations/music
	if State == States.LAMENTING:
		return
	else:
		State = States.LAMENTING
		$LamentationTimer.start()

func show_win_screen():
	$Foreground/WinScreen.show()
	
	
func show_lose_screen():
	$Foreground/LoseScreen.show()

func LookupFaction(factionNum : int):
	for faction in FactionContainer.get_children():
		if faction.Number == factionNum:
			return faction

	
func getRemainingFactions():
	var remainingFactions = []
	for faction in FactionContainer.get_children():
		if faction.State != faction.States.DEAD:
			remainingFactions.push_back(faction)
	return remainingFactions
	

func countRemainingFactions():
	printerr("Level.gd deprecated function countRemainingFactions")
	var remainingAliveFactions = []
	for faction in FactionContainer.get_children():
		if faction.State != faction.States.DEAD:
			remainingAliveFactions.push_back(faction)
	return remainingAliveFactions.size()

###############################################################################
# Outbound Signals
func _on_CelebrationDuration_timeout():
	show_win_screen()
	
#	var playerWon = true
#	resetCamera()
#	# Let main know that the celebration is over. it's ok to show the endscreen
#	if get_parent().has_method("_on_level_completed"):
#		connect("level_completed", get_parent(), "_on_level_completed")
#		emit_signal("level_completed", playerWon)
#		disconnect("level_completed", get_parent(), "_on_level_completed")
#	else:
#		printerr()

func _on_LamentationTimer_timeout():
	show_lose_screen()

#	var playerWon = false
#	resetCamera()
#
#	connect("level_completed", get_parent(), "_on_level_completed")
#	emit_signal("level_completed", playerWon)
#	disconnect("level_completed", get_parent(), "_on_level_completed")

###############################################################################
# Incoming Signals

func _on_new_path_requested(planet, factionObj, cursorObj):
	if State == States.PLAYING:
		spawn_path(planet, factionObj, cursorObj)


func _on_faction_lost(factionObj):
	return # moved validation to the referee object


func _on_faction_won(faction):
	# should only come from the Referee object, because we trust them.
	if faction == PlayerFactionObj:
		print("Level.gd _on_faction_lost claims victory is here! Let the celebrations begin.")
		if State != States.CELEBRATING:
			start_celebration()
	else:
		print("Sorry Player, you lost.") # but we probably don't care, because we want to watch the fireworks
		start_lamentation()
		



func _on_BackButton_pressed():
	print("Level.gd received _on_BackButton_pressed signal")
	
	
	end()
	


func _on_RetryButton_pressed():
	restart()
