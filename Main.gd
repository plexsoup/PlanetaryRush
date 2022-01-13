"""
Load a level
Unload a level
Show an option screen

"""

extends Node2D

#var CurrentLevel : Node2D
var levels: Array = ["res://Levels/Level.tscn"]
var CurrentScene : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# load_level(levels[0]) # this happens when start button is pushed
	randomize()
	global.Main = self
	hide_all_scenes()
	show_single_scene("SplashScreen")

func show_main_camera():
	$MainCamera._set_current(true)
	
	
func show_single_scene(desiredSceneNodeName):
	print("showing scene now: " + desiredSceneNodeName)

	$MainCamera._set_current(true)
	$MainCamera.set_zoom(Vector2(1,1))
#		remove_level()

	var currentSceneCache = CurrentScene
	for sceneNode in $Scenes.get_children():
		
		if sceneNode.name == desiredSceneNodeName:
			sceneNode.show()
			if sceneNode.has_method("activate"):
				print("Main.gd show_single_scene: "+str(sceneNode.get_children()))
				sceneNode.activate()
				CurrentScene = sceneNode
		elif sceneNode == currentSceneCache:
			if sceneNode.has_method("deactivate"):
				sceneNode.deactivate()
			sceneNode.hide()
		else:
			pass

func hide_all_scenes():
	for sceneNode in $Scenes.get_children():
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
	hide_all_scenes()
	show_single_scene("QuickPlay")


	
	
	#global.State = global.States.FIGHTING

################################################################################
# Incoming Signals

# HMM.. Why does main ever care when a single faction lost?
# They should only care that the player lost.
#func _on_faction_lost(factionObj):
#	printerr("Main.gd _on_faction_lost. Consider deprecating in favour of _on_player_lost")
#	if factionObj.IsLocalHumanPlayer:
#		var playerWon = false
#		show_end_screen(playerWon)
#	else:
#		pass # cause, who cares?


#func _on_player_lost(): # coming from Level
#	print("Main.gd got notified that player lost. _on_player_lost()")
#	# should we just trust that Level got it right?
#	var playerWon = false
#	show_end_screen(playerWon)

#func _on_faction_won(factionObj):
#	# This should come after the planets all celebrate.
#	# verify a faction won and the celebration is over,
#	# then show the end-screen
#	printerr("Main.gd _on_faction_won shouldn't have to know anything about faction. Just show the end screen")
#
#	if is_instance_valid(factionObj) == false:
#		printerr("A faction queued free before it won?")
#		return
#	else: # factionObj is valid
#		printerr("Main.gd: _on_faction_won logic: move this to level.gd")
#		if factionObj.IsLocalHumanPlayer:
#			show_end_screen(true)
#		else:
#			if CurrentLevel.FactionContainer.get_child_count() <= 1:
#				show_end_screen(false)

func _on_Quit_pressed():
	$AudioStreamPlayer.stop()
	hide_all_scenes()
	show_single_scene("GoodByeScreen")
	

	yield(get_tree().create_timer(1.5),"timeout")

	get_tree().quit()

func _on_player_requested_scene(sceneName):
	if $Scenes.find_node(sceneName):
		show_single_scene(sceneName)
	
	
#func _on_quickplay_button_pressed():
#	restart()

	
func _on_restart_button_pressed():
	restart()

#func _on_main_menu_requested():
#	show_single_scene("MainMenu")
	
#func _on_Restart_pressed():
#
#	restart()


func _on_DebugTimer_timeout():
	print_debug_info()

#func _on_tutorial_requested():
#	hide_all_scenes()
#	show_single_scene("Tutorial")

func _on_level_completed(sceneObj):
	if sceneObj.name == "SplashScreen":
		show_single_scene("MainMenu")
	
