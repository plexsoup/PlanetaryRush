extends Node2D
class_name OutroScreen, "res://GUI/icons/hand.svg" 

# Declare member variables here. Examples:
signal level_completed(sceneObj)
signal finished(sceneObj)
export var AnimationName = "DropLogo"


func _ready():
	pass


func start(callBackObj):
	# note: callBackObj is responsible for connecting the signal.
	
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play(AnimationName)
	else:
		printerr("Consider putting an AnimationPlayer node in your scene to handle the entry transition: " + self.name)

	if has_node("Timer"):
		$Timer.start()
		
	else:
		_on_Timer_timeout()




func end():
	$AnimationPlayer.stop()
	get_tree().quit()

################################################################################
# Incoming Signals
func _on_Timer_timeout():
	end()
