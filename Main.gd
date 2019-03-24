"""
Load a level
Unload a level
Show an option screen

"""

extends Node2D

var CurrentLevel : Node2D
var levels: Array = ["res://Level.tscn"]

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level(levels[0])
	randomize()
	global.Main = self
	hide_win_screen()

func hide_win_screen():
	get_node("CanvasLayer/WinScreen").hide()

func load_level(level_path):
	var level_scene = load(level_path)
	var newLevel = level_scene.instance()
	add_child(newLevel)
	#newLevel.start()
	CurrentLevel = newLevel
	
func remove_level():
	if CurrentLevel.has_method("end"):
		CurrentLevel.end()
	else:
		CurrentLevel.queue_free()
	
func restart():
	remove_level()
	load_level(levels[0])

func _on_faction_lost(faction):
	var winScreen = get_node("CanvasLayer/WinScreen")
	var titles = get_node("CanvasLayer/WinScreen/MarginContainer/Panel/VBoxContainer/CenterContainer")
	winScreen.show()
	global.pause()
	
	if faction == global.PlayerFaction:
		# you lose
		titles.get_node("Win").hide()
		titles.get_node("Lose").show()
	else:
		# you win
		titles.get_node("Win").show()
		titles.get_node("Lose").hide()
		



func _on_Quit_pressed():
	get_tree().quit()


func _on_Restart_pressed():
	if global.Main.has_method("restart"):
		global.Main.restart()
		$CanvasLayer/WinScreen.hide()
		global.unpause()
		