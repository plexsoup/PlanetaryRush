extends Node2D

onready var FleetContainer : Node2D = $Fleets
onready var BulletContainer : Node2D = $Bullets
onready var PlanetContainer : Node2D = $Planets

var losing_faction

enum States { PLAYING, CELEBRATING }
var State = States.PLAYING


signal faction_lost(faction)
signal player_lost()


func _ready():
	global.level = self
	global.BulletContainer = $Bullets
	call_deferred("start")

func start():
	var aiFaction : int
	if global.PlayerFaction == 1:
		aiFaction = 2
	else:
		aiFaction = 1
	$AI.start(aiFaction)

func _on_new_path_requested(planet):
	if State == States.PLAYING:
		var pathFollowScene = load("res://ShipPath.tscn")
		var pathFollowNode = pathFollowScene.instance()
		pathFollowNode.set_global_position(planet.get_global_position())
		$Paths.add_child(pathFollowNode)
		pathFollowNode.start(planet)

func end():
	call_deferred("queue_free")

func count_player_planets():
	var count = 0
	for planet in $Planets.get_children():
		if planet.Faction == global.PlayerFaction:
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
		
		# this will break when it's AI vs AI
		connect("player_lost", $AI, "_on_player_lost")
		emit_signal("player_lost")
		disconnect("player_lost", $AI, "_on_player_lost")

func _on_LoseCheckTimer_timeout():
	if State != States.CELEBRATING:
		var playerHeldPlanets = count_player_planets()
		if playerHeldPlanets == 0:
			losing_faction = global.PlayerFaction	
			start_celebration()
		$LoseCheckTimer.start()
		
func _on_faction_lost(faction): # coming from AI
	if State != States.CELEBRATING:
		losing_faction = faction
		start_celebration()

func _on_CelebrationDuration_timeout():
	# Note: This will break when you implement AI vs AI
	connect("faction_lost", global.Main, "_on_faction_lost")
	emit_signal("faction_lost", losing_faction)
	disconnect("faction_lost", global.Main, "_on_faction_lost")
	
	
