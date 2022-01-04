extends Node2D

onready var FleetContainer : Node2D = $Fleets
onready var BulletContainer : Node2D = $Bullets
onready var PlanetContainer : Node2D = $Planets
onready var FactionContainer : Node2D = $Factions

var Winning_faction

enum States { INITIALIZING, PLAYING, PAUSED, CELEBRATING }
var State = States.INITIALIZING

export var NumPlanets = 15

signal faction_won(factionObj)

signal switch_faction(planetObj, factionObj)

signal gameplay_started()


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
		
		print("signalling " + factionObj.Name + " that gameplay is starting now.")
		connect("gameplay_started", factionObj, "_on_gameplay_started")
		emit_signal("gameplay_started")
		disconnect("gameplay_started", factionObj, "_on_gameplay_started")
			
	print("Level.gd starting gameplay")
	$CanvasLayer/InLevelGUI.start(getRemainingFactions())
	State = States.PLAYING
	
	

func init_starting_planet(factionObj):
	var neutralPlanets = global.NeutralFactionObj.CurrentPlanetList
	var planetObj = neutralPlanets[randi()%neutralPlanets.size()]
	connect("switch_faction", planetObj, "_on_initialize_faction")
	emit_signal("switch_faction", factionObj)
	disconnect("switch_faction", planetObj, "_on_initialize_faction")

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

func countRemainingFactions():
	printerr("Level.gd deprecated function countRemainingFactions")
	var remainingAliveFactions = []
	for faction in FactionContainer.get_children():
		if faction.State == faction.States.PLAYING:
			remainingAliveFactions.push_back(faction)
	return remainingAliveFactions.size()

func _on_new_path_requested(planet, factionObj, cursorObj):
	if State == States.PLAYING:
		var pathFollowScene = load("res://Paths/ShipPath.tscn")
		var pathFollowNode = pathFollowScene.instance()
		pathFollowNode.set_global_position(planet.get_global_position())
		$Paths.add_child(pathFollowNode)
		pathFollowNode.start(planet, factionObj, cursorObj)

func _on_faction_won(factionObj): # coming from faction.gd
	# we no longer trust factions announcing that they won. Sorry.
	printerr("Level.gd: deprecated function _on_faction_won called. We no longer trust factions announcing that they won. Sorry.")

#	print("Level.gd got a request for celebration. ")
#	print("There are " + str(countRemainingFactions()) + " factions left (including Neutral)")
#
#	if State != States.CELEBRATING:
#		if countRemainingFactions() <= 2: # this is a terrible check
#			start_celebration()

func getRemainingFactions():
	var remainingFactions = []
	for faction in FactionContainer.get_children():
		if faction.State == faction.States.PLAYING:
			remainingFactions.push_back(faction)
	return remainingFactions
	
func _on_faction_lost(factionObj):
	print("Level.gd was notified that " + factionObj.Name + " has no planets or ships remaining.")
	# figure out which factions remain. 
	# Trigger celebration if it's only player and neutral
	# Trigger loss if the player isn't in the list
	var victory = false
	var remainingFactions = getRemainingFactions()
	var numFactionsRemaining = remainingFactions.size()
	for faction in remainingFactions:
		print(faction.Name)
	if remainingFactions.has(global.PlayerFactionObj):
		if numFactionsRemaining == 1:
			victory = true
			Winning_faction = global.PlayerFactionObj
		elif numFactionsRemaining == 2 and remainingFactions.has(global.NeutralFactionObj):
			victory = true
			Winning_faction = global.PlayerFactionObj
	elif remainingFactions.size() == 1:
		victory = true # but not the player
		Winning_faction = remainingFactions[0]
	elif numFactionsRemaining == 2 and remainingFactions.has(global.NeutralFactionObj):
		victory = true
		Winning_faction = remainingFactions[1] # sketchy logic.. what's the easiest way to identify the non-neutral faction?
		
		
	if victory:
		
		print("Level.gd _on_faction_lost claims victory is here! Let the celebrations begin.")
		if State != States.CELEBRATING:
			start_celebration()
			

func _on_CelebrationDuration_timeout():
	# Let main know that the celebration is over. it's ok to show the endscreen
	connect("faction_won", global.Main, "_on_faction_won")
	emit_signal("faction_won", Winning_faction)
	disconnect("faction_won", global.Main, "_on_faction_won")
	
	
