"""
Load a level
Unload a level
Show an option screen

"""

extends Node2D

var CurrentLevel : Node2D
var levels: Array = ["res://Levels/Level.tscn"]

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level(levels[0])
	randomize()
	global.Main = self
	hide_end_screen()

func hide_end_screen():
	get_node("CanvasLayer/EndScreen").hide()

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
	#global.State = global.States.FIGHTING

func _on_faction_lost(faction):
	var endScreen = get_node("CanvasLayer/EndScreen")
	endScreen.show()
	#global.toggle_hard_pause() # the pause menu does this
	
	if faction == global.PlayerFaction:
		endScreen.lose()
	else:
		endScreen.win()


func _on_Quit_pressed():
	$AudioStreamPlayer.stop()
	remove_level()
	$CanvasLayer/PauseMenu.hide()
	$CanvasLayer/EndScreen.hide()
	get_tree().quit()


func _on_Restart_pressed():
	if global.Main.has_method("restart"):
		global.Main.restart()
		$CanvasLayer/EndScreen.hide()
		#global.toggle_hard_pause() # the pause menu does this currently
		
