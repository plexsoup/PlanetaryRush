extends Node2D

onready var FleetContainer : Node2D = $Fleets
onready var BulletContainer : Node2D = $Bullets


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

