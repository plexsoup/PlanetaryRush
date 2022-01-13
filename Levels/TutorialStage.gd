extends Node2D
# spawn level, ingest blueprint

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal finished(nodeObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("finished", get_parent(), "_on_stage_finished")
	hide_children()

func start():
	if self.has_node("blueprint") and is_instance_valid($blueprint):
		$Level.start($blueprint)
	else:
		$Level.start()
	show_children()

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
		
	
func end():
	hide_children()
	emit_signal("finished", self)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
