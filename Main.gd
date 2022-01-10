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
	# load_level(levels[0]) # this happens when start button is pushed
	randomize()
	global.Main = self
	show_single_scene("TitleScreen")

#func show_single_scene(desiredSceneNodeName):
#	print("showing scene now: " + desiredSceneNodeName)
#	if desiredSceneNodeName == "QuickPlay":
#		$MainCamera._set_current(false)
#		load_level(levels[0])
#
#	else:
#		$MainCamera._set_current(true)
#		global.camera = $MainCamera # do we actually really need this?
#		$MainCamera.set_zoom(Vector2(1,1))
#		remove_level()
#
#	for sceneNode in $Scenes.get_children():
#		if sceneNode.name == desiredSceneNodeName:
#			sceneNode.show()
#		else:
#			sceneNode.hide()
		
func show_single_scene(desiredSceneNodeName):
	print("showing scene now: " + desiredSceneNodeName)
#	if desiredSceneNodeName == "QuickPlay":
#		$MainCamera._set_current(false)
#		load_level(levels[0])
#
#	else:
#		global.camera = $MainCamera # do we actually really need this?
	$MainCamera._set_current(true)
	$MainCamera.set_zoom(Vector2(1,1))
#		remove_level()

	for sceneNode in $Scenes.get_children():
		if sceneNode.name == desiredSceneNodeName:
			sceneNode.show()
			if sceneNode.has_method("activate"):
				print(str(sceneNode.get_children()))
				sceneNode.activate()
		else:
			if sceneNode.has_method("deactivate"):
				sceneNode.deactivate()
			sceneNode.hide()



func show_end_screen(playerWon):
	if playerWon:
		$Scenes/EndCredits/EndScreen.win()
	else:
		$Scenes/EndCredits/EndScreen.lose()
	show_single_scene("EndCredits")


#func hide_end_screen():
#	$Scenes/EndCredits.hide()


#func show_start_screen():
#	$Scenes/TitleScreen.show()



func load_level(level_path):
	$MainCamera._set_current(false)
	var level_scene = load(level_path)
	var newLevel = level_scene.instance()
	$Scenes/QuickPlay.add_child(newLevel)
	#newLevel.start()
	CurrentLevel = newLevel
	
	
func remove_level():
	if is_instance_valid(CurrentLevel):
		if CurrentLevel.has_method("end"):
			CurrentLevel.end()
		else:
			CurrentLevel.queue_free()
	else:
		printerr("Main.gd: someone is calling remove_level, but it seems like level is already gone.")

func print_debug_info():
	if global.Debug:
		# print_tree_pretty()
#		print("We could put more debug info in Main.gd print_debug_info.")
#		print("But right now it's empty.")
#		print("If you need it, you could add a print_tree_pretty() call.")
		pass
		
func updateInGameTimers(speed):
	printerr("Main.gd updateInGameTimers needs development")
	var timerNodes = get_tree().get_nodes_in_group("InGameTimers")
	for timerNode in timerNodes:
		pass

	
func restart():
	print("Main.gd restart() called")
	show_single_scene("QuickPlay")


	
	
	#global.State = global.States.FIGHTING

################################################################################
# Incoming Signals

# HMM.. Why does main ever care when a single faction lost?
# They should only care that the player lost.
func _on_faction_lost(factionObj):
	printerr("Main.gd _on_faction_lost. Consider deprecating in favour of _on_player_lost")
	if factionObj.IsLocalHumanPlayer:
		var playerWon = false
		show_end_screen(playerWon)
	else:
		pass # cause, who cares?


func _on_player_lost(): # coming from Level
	print("Main.gd got notified that player lost. _on_player_lost()")
	# should we just trust that Level got it right?
	var playerWon = false
	show_end_screen(playerWon)

func _on_faction_won(factionObj):
	# This should come after the planets all celebrate.
	# verify a faction won and the celebration is over,
	# then show the end-screen
	
	if is_instance_valid(factionObj) == false:
		printerr("A faction queued free before it won?")
		return
	else: # factionObj is valid
		if factionObj.IsLocalHumanPlayer:
			show_end_screen(true)
		else:
			if CurrentLevel.FactionContainer.get_child_count() <= 1:
				show_end_screen(false)

func _on_Quit_pressed():
	$AudioStreamPlayer.stop()
	remove_level()
	$Scenes/TitleScreen.hide()
	$Scenes/EndCredits.hide()
	get_tree().quit()

func _on_restart_button_pressed():
	restart()

func _on_main_menu_requested():
	show_single_scene("TitleScreen")
	
func _on_Restart_pressed():
		
	restart()


func _on_DebugTimer_timeout():
	print_debug_info()

func _on_tutorial_requested():
	show_single_scene("Tutorial")
