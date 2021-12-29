extends Node

var options : Dictionary = {
	"debug" : false,
	"num_planets" : 10,
	"difficulty" : 0 # 0, 1, 2
}

enum Difficulties { EASY, NORMAL, HARD }
enum States { STARTSCREEN, OPTIONS_MENU, FIGHTING, SHOPPING, PAUSED, ENDSCREEN }
var State = States.STARTSCREEN
var Ticks : int = 0

var Debug : bool = true
var game_speed: float = 0.2
var previous_game_speed: float
var screen_size : Vector2
var cursor : Area2D
var Main : Node2D
var level : Node2D
var BulletContainer : Node2D
var planet_container : Node2D


var NumFactions : int = 2

var FactionColors : PoolColorArray = [
		Color(0.0,0.0,0.8,0.5), 
		Color(0.8,0.0,0.0,0.5), 
		Color(0.0,0.8,0.0,0.5), 
		Color(0.8,0.8,0.0,0.5), 
		Color(0.8,0.0,0.8,0.5), 
		Color(0.0,0.8,0.8,0.5), 
		Color(0.8,0.0,0.8,0.5),
		Color(0.8,0.8,0.8,0.5),
	]
var PlayerFaction : int = 1
var camera : Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().get_size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Ticks += 1



func toggle_hard_pause():
	if State == States.FIGHTING:
		get_tree().paused = true
		State = States.OPTIONS_MENU
	elif State == States.OPTIONS_MENU:
		get_tree().paused = false
		State = States.FIGHTING
	elif State == States.STARTSCREEN:
		get_tree().paused = false
		State = States.FIGHTING
		
func toggle_soft_pause():
	#TODO walk through the scene tree and pause/unpause all the timers?
	if State == States.PAUSED:
		game_speed = previous_game_speed
		State = States.FIGHTING
	else: # **** This will cause problems later. Guaranteed. should be elif or "match" (switch/case).
		previous_game_speed = game_speed
		game_speed = 0.0
		State = States.PAUSED
		
		
