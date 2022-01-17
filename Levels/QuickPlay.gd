extends Node2D


var CallBackObj

signal finished



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start(callBackObj):
	CallBackObj = callBackObj
	spawnLevel()

	
func spawnLevel():
	var levelScene = load("res://Levels/Level.tscn")
	var level = levelScene.instance()
	self.add_child(level)
	level.name = "Level"
	level.start()
	$EndScreen.hide()
	
func deactivate():
	var level
	if has_node("Level"):
		level = get_node("Level")
	if level and is_instance_valid(level):
		level.end()

	
func _on_level_completed(isPlayerWinner):
	print("Congratulations. Now we have to connect up some signals and show the win screen.")
	
	$Level.end()
	global.Main.show_main_camera()
	if isPlayerWinner:
		$EndScreen.win()
	else:
		$EndScreen.lose()
	$EndScreen.show()
	
func _on_Restart_pressed():
	$EndScreen.hide()
	$Level.show() # might need to spawn a new level, since we killed the old one already?
	$Level.start()
	
