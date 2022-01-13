extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	print(str(get_children()))
	$Level.start()
	$EndScreen.hide()
	
func deactivate():
	$Level.end()

	
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
	
