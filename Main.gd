"""
Load a level
Unload a level
Show an option screen

"""

extends Node2D

#var CurrentLevel : Node2D
#var levels: Array = ["res://Levels/Level.tscn"]
var CurrentScene : Node2D
var Scenes : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	Scenes = {
		"SplashScreen" : $SplashScreen,
		"Game" : $Game,
		"EndScreen" : $EndScreen
	}


	show_single_scene(Scenes["SplashScreen"]) # requires scenes to have a .start() function
	
	
func show_single_scene(sceneObj):
	print("Main.gd show_single_scene called with " + sceneObj.name)
	$MainCamera._set_current(true)
	$MainCamera.set_zoom(Vector2(1,1))

	for sceneName in Scenes:
		if Scenes[sceneName] != sceneObj:
			Scenes[sceneName].hide()
		else:
			Scenes[sceneName].show()
			
			if not Scenes[sceneName].is_connected("finished", self, "_on_scene_finished"):
				Scenes[sceneName].connect("finished", self, "_on_scene_finished")
				Scenes[sceneName].start(self)
			else:
				print("Scene already has signals connected. starting anyways")
				Scenes[sceneName].start(self)

func updateInGameTimers(speed):
	#refactor. Move this to Level
	printerr("Main.gd updateInGameTimers needs development")
	var timerNodes = get_tree().get_nodes_in_group("InGameTimers")
	for timerNode in timerNodes:
		pass

	
func restart():
	show_single_scene(Scenes["QuickPlay"])


func _on_Quit_pressed():
	$AudioStreamPlayer.stop()
	show_single_scene("GoodByeScreen")
	yield(get_tree().create_timer(1.5),"timeout")
	get_tree().quit()

func _on_player_requested_scene(sceneName):
	printerr("Do we still use _on_player_requested_scene?")
	if $Scenes.find_node(sceneName):
		show_single_scene(sceneName)
	
func _on_restart_button_pressed():
	restart()



func _on_scene_finished(sceneObj):
	
	if sceneObj == Scenes["SplashScreen"]:
		show_single_scene(Scenes["Game"])
	elif sceneObj == Scenes["Game"]:
		show_single_scene(Scenes["EndScreen"])




#func _on_menu_finished(sceneObj):
#	sceneObj.hide()
#	show_single_scene(Scenes["SplashScreen"])
