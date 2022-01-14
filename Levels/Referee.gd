extends Node
# monitor planet exchanges
# count number of planets
# count number of remaining factions
# declare loss or victory


# Declare member variables here. Examples:
var Level : Node2D
var Factions : Node2D
var Planets : Node2D
var Player : Node2D

enum States { PAUSED, ACTIVE, DEAD }
var State = States.PAUSED

signal faction_won(factionObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(levelObj, factionContainer, planetContainer, playerObj):
	Level = levelObj
	Player = playerObj
	Factions = factionContainer
	Planets = planetContainer
	$InspectionTimer.start()
	State = States.ACTIVE
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# probably don't need this on a timer. It'd be just as effective on signals
	pass

func check_win_conditions():
	if is_instance_valid(Planets):
		var allPlanets : int = Planets.get_all_planets().size()
		var neutralPlanets : int  = Planets.get_faction_planets(null).size()
		var playerPlanets : int  = Planets.get_faction_planets(Player).size()

		if playerPlanets == allPlanets:
			notifyLevelFactionWon(Player)
		elif not Level.RequireNeutralCapture:
			if playerPlanets + neutralPlanets == allPlanets:
				notifyLevelFactionWon(Player)
		else:
			return false

		if playerPlanets == 0:
			notifyLevelFactionWon(null) 
			printerr("Referee.gd has no mechanism to determin which AI actually won yet.")
			

################################################################
# Outgoing Signals

func notifyLevelFactionWon(faction): # ??? who?, when?
	connect("faction_won", Level, "_on_faction_won")
	emit_signal("faction_won", faction)
	disconnect("faction_won", Level, "_on_faction_won")

################################################################
# Incoming Signals

func _on_planet_switched_faction(planet, newFaction):
	# coming from planet

	# Beware: this will happen a bunch of times as the level becomes initialized.
	check_win_conditions()

func _on_InspectionTimer_timeout():
	#check_win_conditions()
	pass
	
