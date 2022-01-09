extends Node2D

onready var FleetContainer : Node2D = $Fleets
onready var BulletContainer : Node2D = $Bullets
onready var PlanetContainer : Node2D = $Planets
onready var FactionContainer : Node2D = $Factions
onready var PathContainer : Node2D = $Paths

var Winning_faction

enum States { INITIALIZING, PLAYING, PAUSED, CELEBRATING }
var State = States.INITIALIZING

export var NumPlanets = 15

signal faction_won(factionObj)

signal set_initial_faction(factionObj)

signal gameplay_started()

var PathFollowScene = preload("res://Paths/ShipPath.tscn")

func _ready():
	global.level = self
	global.BulletContainer = $Bullets
	call_deferred("start")
	# this is causing a problem. The AI starts before the player has clicked out of the menu
	

func start():
	# spawn a bunch of neutral planets, then change NumFactions to their unique faction.
	spawn_factions(global.NumFactions + 1)  # produces factionObj's in FactionContainer
	spawn_planets(global.NeutralFactionObj, NumPlanets)
	
	for factionObj in FactionContainer.get_children():
		if factionObj.IsNeutralFaction == false:
			init_starting_planet(factionObj)
			spawn_cursor(factionObj)
		
		connect("gameplay_started", factionObj, "_on_gameplay_started")
		emit_signal("gameplay_started")
		disconnect("gameplay_started", factionObj, "_on_gameplay_started")
			
	print("Level.gd starting gameplay")
	$Foreground/InLevelGUI.start(getRemainingFactions())
	State = States.PLAYING
	
	

func init_starting_planet(factionObj):
	var neutralPlanets = global.NeutralFactionObj.CurrentPlanetList
	var planetObj = utils.GetRandElement(neutralPlanets)
	connect("set_initial_faction", planetObj, "_on_initialize_faction")
	emit_signal("set_initial_faction", factionObj)
	disconnect("set_initial_faction", planetObj, "_on_initialize_faction")



func spawn_planets(factionObj, totalNumber):
	PlanetContainer.spawnPlanets(factionObj, totalNumber) # make sure this happens after factions are created

func spawn_factions(numFactions):
	print("Level.gd: spawning " + str(numFactions) + " Factions")
	
	for factionNum in range(numFactions):
		var isHuman = false
		var isNeutralFaction = false
		if factionNum == global.PlayerFactionNum:
			isHuman = true
		elif factionNum == global.NeutralFactionNum:
			isNeutralFaction = true
		spawn_faction(factionNum, global.FactionColors[factionNum], isHuman, isNeutralFaction)
		print("spawning faction: " + str(factionNum))

func spawn_faction(factionNum, color, isHuman, isNeutralFaction):
	var factionScene = load("res://Players/Faction.tscn")
	var factionNode = factionScene.instance()
	var factionName : String = ""
	$Factions.add_child(factionNode)
	if isHuman:
		factionName = "Player 1"
	elif isNeutralFaction:
		factionName = "Neutral"
		global.NeutralFactionObj = factionNode
	else:
		factionName = "Faction " + str(factionNum)
	factionNode.start(factionNum, factionName, color, isHuman, isNeutralFaction)


func spawn_cursor(factionObj): # this could probably be moved into Faction
	
	# each cursor acts as a player controller, to receive input and draw paths
	var cursorScene = load("res://Players/Cursor.tscn")
	var cursorNode = cursorScene.instance()
	#cursorNode.set_global_position(Vector2(1,1))
	$Cursors.add_child(cursorNode)
	cursorNode.start(factionObj, factionObj.IsLocalHumanPlayer)
	factionObj.CursorObj = cursorNode

func spawn_path(planet, factionObj, cursorObj):
	
	var pathFollowNode = PathFollowScene.instance()
	pathFollowNode.set_global_position(planet.get_global_position())
	PathContainer.add_child(pathFollowNode)
	pathFollowNode.start(planet, factionObj, cursorObj)



func end():
	call_deferred("queue_free")


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
			 
		$CelebrationDuration.start()
		
		for planet in PlanetContainer.get_children():
			if planet.has_method("celebrate"):
				planet.celebrate()


func getRemainingFactions():
	var remainingFactions = []
	for faction in FactionContainer.get_children():
		if faction.State == faction.States.PLAYING:
			remainingFactions.push_back(faction)
	return remainingFactions
	

func countRemainingFactions():
	printerr("Level.gd deprecated function countRemainingFactions")
	var remainingAliveFactions = []
	for faction in FactionContainer.get_children():
		if faction.State == faction.States.PLAYING:
			remainingAliveFactions.push_back(faction)
	return remainingAliveFactions.size()

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
		return

	var victory = false
	var remainingFactions = getRemainingFactions()
	if not remainingFactions.has(global.PlayerFactionObj) and remainingFactions.size() == 1:
		# player lost
		victory = true # but not the player
		Winning_faction = remainingFactions[0]
	else:
		remainingFactions.erase(global.PlayerFactionObj)
		remainingFactions.erase(global.NeutralFactionObj)
		if remainingFactions.size() == 0: # all enemy factions gone
				victory = true
				Winning_faction = global.PlayerFactionObj
			
		
	if victory:
		
		print("Level.gd _on_faction_lost claims victory is here! Let the celebrations begin.")
		if State != States.CELEBRATING:
			start_celebration()
			

func _on_CelebrationDuration_timeout():
	# Let main know that the celebration is over. it's ok to show the endscreen
	connect("faction_won", global.Main, "_on_faction_won")
	emit_signal("faction_won", Winning_faction)
	disconnect("faction_won", global.Main, "_on_faction_won")
	
	
