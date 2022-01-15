extends Node2D


# Declare member variables here. Examples:
signal level_completed(sceneObj)
export var AnimationName = "DropLogo"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate(callBackObj):
	$AnimationPlayer.play(AnimationName)

	
func deactivate():
	$AnimationPlayer.stop()


func _on_Timer_timeout():
	connect("level_completed", global.Main, "_on_level_completed")
	emit_signal("level_completed", self)
	disconnect("level_completed", global.Main, "_on_level_completed")
