extends Node2D

# might not need these. but they could help with scene navigation
export var NextSceneName : String
export var PreviousSceneName : String

export var IsCurrent : bool = false
export var Bespoke : bool = false # bespoke levels are handcrafted in the Godot 2D editor. Useful for campaign

export var DesiredNumPlanets : int
export var DesiredNumFactions : int


onready var FleetContainer : Node2D = $Fleets
onready var BulletContainer : Node2D = $Bullets
onready var PlanetContainer : Node2D = $Planets
onready var FactionContainer : Node2D = $Factions
onready var PathContainer : Node2D = $Paths
#onready var CursorsContainer : Node2D = $Cursors

var Winning_faction

enum States { INITIALIZING, PLAYING, PAUSED, CELEBRATING, LAMENTING }
var State = States.INITIALIZING

var NumPlanets : int = 0

signal level_completed(factionObj)
#signal player_lost()
signal set_initial_faction(factionObj)
signal gameplay_started()

var PathFollowScene = preload("res://Paths/ShipPath.tscn")

func _ready():
	#call_deferred("start")
	# this is causing a problem. The AI starts before the player has clicked out of the menu
	print("Hi, I'm level.gd, inside: " + get_parent().name)
	

func start():
	global.level = self
	global.BulletContainer = $Bullets

	NumPlanets = DesiredNumPlanets
	
	# spawn a bunch of neutral planets, then change NumFactions to their unique faction.
	if not Bespoke:
		spawn_factions(global.NumFactions)  # produces factionObj's in FactionContainer
		spawn_planets(NumPlanets)
		for faction in FactionContainer.get_children():
			var randomPlanet = PlanetContainer.get_random_neutral_planet()
			randomPlanet.switch_faction(faction)
			randomPlanet.set_initial_population(2)
	else:
		intake_bespoke_elements()

	print("Level.gd starting gameplay")

	spawn_in_level_GUI()
	State = States.PLAYING
	
	
	
func spawn_in_level_GUI():
	print("Level.gd spawn_in_level_GUI called")
	# unfortunately, the in-level gui has to be in a CanvasLayer, but they can't be hidden, so you have to hide the gui in the inspector
	var numFactions = global.NumFactions # refactor: this shouldn't be in Global anymore.
	var factions = getRemainingFactions()
	
	$Foreground/InLevelGUI.show()
	$Foreground/InLevelGUI.start(self, factions)
	


func spawn_planets(totalNumber):
	PlanetContainer.spawnPlanets(totalNumber, self) # make sure this happens after factions are created

func spawn_factions(numFactions):
	print("Level.gd: spawning " + str(numFactions) + " Factions")
	
	for factionNum in range(numFactions):
		var isHuman = false
		
		if factionNum == global.PlayerFactionNum:
			isHuman = true
		spawn_faction(factionNum, global.FactionColors[factionNum], isHuman)
		print("spawning faction: " + str(factionNum))

func spawn_faction(factionNum, color, isHuman):
	var factionScene = load("res://Players/Faction.tscn")
	var factionNode : Node2D
	var factionName : String
	
	if isHuman:
		factionName = "Player 1"
	else:
		factionName = "Faction " + str(factionNum)
	
	factionNode = factionScene.instance()
	$Factions.add_child(factionNode)
	factionNode.start(self, factionNum, factionName, color, isHuman)

#func spawn_cursors(): # move this into faction (isHuman can decide what type of cursor to use)
#	for factionObj in FactionContainer.get_children():
#		if factionObj.IsNeutralFaction == false:
#			init_starting_planet(factionObj)
#			spawn_cursor(factionObj)
#
#		connect("gameplay_started", factionObj, "_on_gameplay_started")
#		emit_signal("gameplay_started")
#		disconnect("gameplay_started", factionObj, "_on_gameplay_started")

	
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

func intake_bespoke_elements():
	# look at the level and identify existing planets, factions, etc.
	# make sure they get catalogues and initialized correctly
	print("Level.gd is identifying objects placed manually in the level designer.")
	var containers = [PlanetContainer, FactionContainer]

	var i = 0
	if FactionContainer.get_child_count() > 0:
		for faction in FactionContainer.get_children():
			# factions expect: number, myName, myColor, isLocalHuman, levelObj
			faction.start(self, i, "Faction " + str(i), global.FactionColors[i], false)
	

	if PlanetContainer.get_child_count() > 0:
		for planet in PlanetContainer:
			planet.start()
			# planets expect size, factionObj
			

func remove_entities():
	
	var containers = [PlanetContainer, FleetContainer, PathContainer, FactionContainer]
	for container in containers:
		for entity in container.get_children():
			if entity.has_method("end"):
				entity.end()
			else:
				entity.call_deferred("queue_free")
	

func end():
	print("Level " + self.name + " is ending. Hiding the gui (GUI has to be in a canvas layer, but they can't be hidden, so you have to hide the stuff inside.)")
	pass # I don't know why this isn't working
	#call_deferred("queue_free")
	$Foreground/InLevelGUI.hide()
	remove_entities()

func count_player_planets():
	var count = 0
	for planet in $Planets.get_children():
		if planet.FactionObj.IsLocalHumanPlayer:
			count += 1
	return count

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
	var playerWon = true
	
	# Let main know that the celebration is over. it's ok to show the endscreen
	if get_parent().has_method("_on_level_completed"):
		connect("level_completed", get_parent(), "_on_level_completed")
		emit_signal("level_completed", playerWon)
		disconnect("level_completed", get_parent(), "_on_level_completed")
	else:
		printerr()

func _on_LamentationTimer_timeout():
	var playerWon = false
	connect("level_completed", get_parent(), "_on_level_completed")
	emit_signal("level_completed", playerWon)
	disconnect("level_completed", get_parent(), "_on_level_completed")

###############################################################################
# Incoming Signals

func _on_new_path_requested(planet, factionObj, cursorObj):
	if State == States.PLAYING:
		spawn_path(planet, factionObj, cursorObj)
		
#func _on_path_no_longer_required(planet, factionObj):
#	# find a path for faction, from planet, with no fleets.
#	var paths = PathContainer.get_children()
#	for path in paths:
#		if path.FactionObj = factionObj and AssignedFleet == null:
#			printerr("hmm.. how do we identify paths?")

func _on_faction_lost(factionObj):
	print("Level.gd was notified that " + factionObj.name + " has no planets or ships remaining.")
	# figure out which factions remain. 
	# Trigger celebration if it's only player and neutral
	# Trigger loss if the player isn't in the list
	if factionObj == global.PlayerFactionObj:
		# player lost.. show the end screen
		print("Sorry Player, you lost.") # but we probably don't care, because we want to watch the fireworks
		start_lamentation()

	var victory = false
	var remainingFactions = getRemainingFactions()
	if not remainingFactions.has(global.PlayerFactionObj) and remainingFactions.size() == 1:
		# player lost
		victory = true # but not the player
		Winning_faction = remainingFactions[0]
	else:
		remainingFactions.erase(global.PlayerFactionObj)
		if remainingFactions.size() == 0: # all enemy factions gone
				victory = true
				Winning_faction = global.PlayerFactionObj
			
		
	if victory:
		
		print("Level.gd _on_faction_lost claims victory is here! Let the celebrations begin.")
		if State != States.CELEBRATING:
			start_celebration()
			



