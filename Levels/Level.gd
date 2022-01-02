extends Node2D

onready var FleetContainer : Node2D = $Fleets
onready var BulletContainer : Node2D = $Bullets
onready var PlanetContainer : Node2D = $Planets
onready var FactionContainer : Node2D = $Factions

var Winning_faction

enum States { PLAYING, CELEBRATING }
var State = States.PLAYING


signal faction_won(factionObj)
#signal player_lost()


func _ready():
	global.level = self
	global.BulletContainer = $Bullets
	call_deferred("start")
	# this is causing a problem. The AI starts before the player has clicked out of the menu
	

func start():
	spawn_factions(global.NumFactions + 1)  # produces factionObj's in FactionContainer
	for factionObj in FactionContainer.get_children():
		print("spawning faction " + str(factionObj.Number))
		spawn_planets(factionObj)
		if factionObj.IsNeutralFaction == false:
			spawn_cursor(factionObj)

func spawn_planets(factionObj):
	PlanetContainer.spawnPlanets(factionObj) # make sure this happens after factions are created

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
		

func spawn_faction(factionNum, color, isHuman, isNeutralFaction):
	var factionScene = load("res://Players/Faction.tscn")
	var factionNode = factionScene.instance()
	var factionName : String = ""
	$Factions.add_child(factionNode)
	if isHuman:
		factionName = "Player 1"
	elif isNeutralFaction:
		factionName = "Neutral"
	else:
		factionName = "Faction " + str(factionNum)
	factionNode.start(factionNum, factionName, color, isHuman, isNeutralFaction)
	if isNeutralFaction:
		global.NeutralFactionObj = factionNode
	


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
	var remainingAliveFactions = []
	for faction in FactionContainer.get_children():
		if faction.State == faction.States.ALIVE:
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
	# verify first
	print("Level.gd got a request for celebration. ")
	print("There are " + str(countRemainingFactions()) + " factions left")
	
	if State != States.CELEBRATING:
		if countRemainingFactions() <= 2: # this is a terrible check
			start_celebration()
	

func _on_CelebrationDuration_timeout():
	# Let main know that the celebration is over. it's ok to show the endscreen
	connect("faction_won", global.Main, "_on_faction_won")
	emit_signal("faction_won", Winning_faction)
	disconnect("faction_won", global.Main, "_on_faction_won")
	
	
