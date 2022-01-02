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
	if CurrentLevel and CurrentLevel != null:
		if CurrentLevel.has_method("end"):
			CurrentLevel.end()
		else:
			CurrentLevel.queue_free()

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
	remove_level()
	load_level(levels[0])
	#global.State = global.States.FIGHTING

func _on_faction_lost(factionObj):
	
#	#global.toggle_hard_pause() # the pause menu does this
#
	if factionObj.IsLocalHumanPlayer:
		var endScreen = get_node("CanvasLayer/EndScreen")
		endScreen.show()
		endScreen.lose()
#	else:
#		if CurrentLevel.FactionContainer.get_child_count() <= 1:
#			endScreen.win()

func _on_faction_won(factionObj):
	# This should come after the planets all celebrate.
	# verify a faction won and the celebration is over,
	# then show the end-screen
	
	if is_instance_valid(factionObj) == false:
		printerr("A faction queued free before it won?")
		return
	else: # factionObj is valid
		var endScreen = get_node("CanvasLayer/EndScreen")
		endScreen.show()
		#global.toggle_hard_pause() # the pause menu does this
		
		if factionObj.IsLocalHumanPlayer:
			endScreen.win()
		else:
			if CurrentLevel.FactionContainer.get_child_count() <= 1:
				endScreen.lose()

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
		


func _on_DebugTimer_timeout():
	print_debug_info()
