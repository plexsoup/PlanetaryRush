extends Node2D

export var levelScene : PackedScene

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
	#var levelScene = load("res://Levels/Level.tscn")
	var level = levelScene.instance()
	self.add_child(level)
	level.name = "Level"
	if level.has_signal("finished"):
		level.connect("finished", self, "_on_level_finished")
	else:
		printerr("Level has no 'finished' signal to connect")
	level.start(self)
	
	#$EndScreen.hide()
	
func deactivate():
	var level
	if has_node("Level"):
		level = get_node("Level")
	if level and is_instance_valid(level):
		if level.has_method("end"):
			level.end()
		else:
			level.call_deferred("queue_free")


func _on_level_finished(scene):
	# can probably just ignore the scene.. you know it's coming from your Level.tscn

	print("Quickplay.gd received _on_level_finished signal")

	if has_signal("finished"):
		print(get_signal_connection_list("finished"))
	print("emitting signal finished")
	emit_signal("finished", self) # tell the dynamic menu we're done.
	

	
func _on_Restart_pressed():
	print("_on_Restart_pressed")
	$EndScreen.hide()
	$Level.show() # might need to spawn a new level, since we killed the old one already?
	$Level.start()
	
