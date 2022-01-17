extends Node2D


# Declare member variables here. Examples:
var CallBackObj

signal finished()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for child in get_children():
		if child.has_signal("ended"):
			child.connect("ended", self, "_on_stage_ended")
	
	
	#activate(self)

func construct_tutorial_stage_selection_menu():
	$DynamicMenu.start(self, self)

func show_tutorial_stage_selection_menu():
	$DynamicMenu.show()
	#$DynamicMenu.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start(callBackObj):
	activate(callBackObj)
	

func activate(callBackObj):
	print("Tutorial.gd: activate()")
	CallBackObj = callBackObj # who to tell when we're finished
	
	hide_all_stages()
	
	$DynamicMenu.show()
	$DynamicMenu.start() # relying on the path to be set manually in the inspector
	
	
	
func deactivate():
	#$"Stage 1".end()
	pass
	#can't be queuing free the hand-placed bespoke assets.

func hide_all_stages():
	for scene in get_children():
		if scene.has_method("hide"):
			scene.hide()
		elif scene.is_class("CanvasLayer"):
			scene.get_child[0].hide()
			
			

func _on_stage_ended(stage):
	printerr("Tutorial.gd has redundancy: _on_stage_ended and _on_stage_finished do the same thing. Pick one.")
	show_tutorial_stage_selection_menu()
	# or just: start_next_stage()
	
func _on_stage_finished(stage):
	printerr("Tutorial.gd has redundancy: _on_stage_ended and _on_stage_finished do the same thing. Pick one.")
	show_tutorial_stage_selection_menu()
	

func _on_Stage_Button_pressed(stageName):
	
	if self.has_node(stageName):
		
#		for stageNode in get_children():
#			if stageNode.has_method("deactivate"):
#				stageNode.deactivate()
#			stageNode.hide()
		hide_all_stages()
		var newStageNode = get_node(stageName)
#		printerr("Tutorial.gd: We need to settle on an init function. Is it activate() or start()?")
#		if newStageNode.has_method("activate"):
#			newStageNode.activate()
		if newStageNode.has_method("start"):
			newStageNode.start()
			newStageNode.show()
		
func _on_menu_finished():
	# signal main that the tutorial menu is done. User wants to get back to main menu.
	printerr("Tutorial.gd needs development in _on_menu_finished")
	connect("finished", CallBackObj, "_on_tutorial_finished")
	emit_signal("finished")
	disconnect("finished", CallBackObj, "_on_tutorial_finished")
	
func _on_level_finished(scene):
	# can probably just ignore the scene.. you know it's coming from your Level.tscn

	print("Tutorial.gd received _on_level_finished signal")

	if has_signal("finished"):
		print(get_signal_connection_list("finished"))
	print("emitting signal finished")
	emit_signal("finished", self) # tell the dynamic menu we're done.
	
