extends Node

var options : Dictionary = {
	"debug" : false,
	"num_planets" : 10,
	"difficulty" : 0 # 0, 1, 2
}

enum Difficulties { EASY, NORMAL, HARD }

var Debug : bool = false
var game_speed: float = 0.5
var screen_size : Vector2
var cursor : Area2D
var Main : Node2D
var level : Node2D
var BulletContainer : Node2D
var planet_container : Node2D
var FactionColors : Array = [
		Color.darkgray,
		Color.blue, 
		Color.red, 
	]
var PlayerFaction : int = 1
var camera : Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().get_size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func pause():
	get_tree().paused = true
	
func unpause():
	get_tree().paused = false
	
	