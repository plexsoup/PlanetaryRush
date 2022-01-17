extends Node2D


# Declare member variables here. Examples:
signal level_completed(sceneObj)
signal finished()
export var AnimationName = "DropLogo"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start(callBackObj):
	$AnimationPlayer.play(AnimationName)


func activate(callBackObj):
	start(callBackObj)

func deactivate():
	$AnimationPlayer.stop()


func _on_Timer_timeout():
	#emit_signal("level_completed", self)
	emit_signal("finished")
