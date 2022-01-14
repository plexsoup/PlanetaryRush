extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for child in get_children():
		if child.has_signal("ended"):
			child.connect("ended", self, "_on_stage_ended")
	
	
	pass # Replace with function body.

func show_tutorial_stage_selection_menu():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	print("Tutorial.gd: activate()")
	$DynamicMenu.show()
	$DynamicMenu.start() # relying on the path to be set manually in the inspector
	
func deactivate():
	#$"Stage 1".end()
	pass
	#can't be queuing free the hand-placed bespoke assets.

func _on_stage_ended(stage):
	show_tutorial_stage_selection_menu()
	# or just: start_next_stage()
	


func _on_Stage_Button_pressed(stageName):
	if self.has_node(stageName):
		
		for stageNode in get_children():
			if stageNode.has_method("deactivate"):
				stageNode.deactivate()
			stageNode.hide()
		var newStageNode = get_node(stageName)
#		printerr("Tutorial.gd: We need to settle on an init function. Is it activate() or start()?")
#		if newStageNode.has_method("activate"):
#			newStageNode.activate()
		if newStageNode.has_method("start"):
			newStageNode.start()
			newStageNode.show()
		
		
