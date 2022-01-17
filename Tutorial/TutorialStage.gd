extends Node2D
# spawn level, ingest blueprint

var Level

signal finished(nodeObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	# The Dynamic Menu should establish the callback for the finished signal.

	pass

func start(callbackObj):

	spawnLevel()

	# if it's a blueprint level, import the blueprint
#	if self.has_node("blueprint") and self.has_node("Level"):
#		$Level.start($blueprint)
#		$blueprint.hide()
#	elif self.has_node("Level") and is_instance_valid($Level):
#			$Level.start() # no blueprint
#	else: # probably just a regular menu
#		pass

func spawnLevel():
	var levelScene = preload("res://Levels/Level.tscn")
	var level = levelScene.instance()
	self.add_child(level)
	level.name = "Level"
	level.start($blueprint)
	Level = level

func show_children():
	# note, CanvasLayers by default have no hide or show methods.
	# canvas layers will require an attached script to implement them.
	# use res://GUI/CanvasLayerHack.gd on those nodes
	for child in get_children():
		if child.has_method("show"):
			child.show()
		else:
			printerr(child.name  + " has no show() method. Consider attaching the res://GUI/CanvasLayerHack.gd script to the canvas layer nodes.")
		

func hide_children():
	for child in get_children():
		if child.has_method("hide"):
			child.hide()
		else:
			printerr(child.name  + " has no hide() method. Consider attaching the res://GUI/CanvasLayerHack.gd script to canvas layer nodes.")

func terminate_level():
	if is_instance_valid(Level):
		Level.call_deferred("queue_free")
	else:
		printerr("TutorialStage.gd may have redundant functionality in terminate_level. Level is already gone.")
	
func end():
	#global.Main.show_main_camera() # Main can probably handle this when it gets control back via menus
	hide_children()
	terminate_level()
	emit_signal("finished", self)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_level_completed(isPlayerWinner):
	if isPlayerWinner:
		end()
	else:
		end()
	
