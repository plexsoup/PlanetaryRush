extends Node2D

onready var FleetContainer : Node2D = $Fleets
onready var BulletContainer : Node2D = $Bullets

signal faction_lost(faction)

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
	var pathFollowScene = load("res://ShipPath.tscn")
	var pathFollowNode = pathFollowScene.instance()
	pathFollowNode.set_global_position(planet.get_global_position())
	add_child(pathFollowNode)
	pathFollowNode.start(planet)

func end():
	call_deferred("queue_free")

func count_player_planets():
	var count = 0
	for planet in $Planets.get_children():
		if planet.Faction == global.PlayerFaction:
			count += 1
	return count

func _on_LoseCheckTimer_timeout():
	var playerHeldPlanets = count_player_planets()
	if playerHeldPlanets == 0:
		print(self.name, " triggered _on_LoseCheckTimer_timeout")
		connect("faction_lost", global.Main, "_on_faction_lost")
		emit_signal("faction_lost", global.PlayerFaction)
		disconnect("faction_lost", global.Main, "_on_faction_lost")