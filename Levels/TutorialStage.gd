extends Node2D
# spawn level, ingest blueprint


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start():
	if is_instance_valid($blueprint):
		$Level.start($blueprint)
	else:
		$Level.start()
	
func end():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
