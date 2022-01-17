extends Node2D
# Place this node inside a node, with siblings for each button item

export var ScenesContainerPath : String = ""
export var ButtonsContainerPath : String = "Control/bgImage/CenterContainer/PanelContainer/VBoxContainer/Label"
export var MenuName : String = "Dynamic Menu"
export var BackgroundImage : Texture
var ScenesContainer : Node
var ButtonsContainer : Control

var CallBackObj : Node # who to tell when we're done or when a scene completes or whatever

#signal finished()

func start(scenesContainer : Node = null, callBackObj : Node = null):
	if has_node(ButtonsContainerPath):
		ButtonsContainer = get_node(ButtonsContainerPath)
	else:
		printerr("DynamicMenu.gd: invalid button container on " + str(self) + self.name )
		return
	
	# cleanup first.. cause this was creating endless buttons
	if ButtonsContainer.get_child_count() > 0:
		for button in ButtonsContainer.get_children():
			button.call_deferred("queue_free")
			
	if scenesContainer == null:
		scenesContainer = get_node(ScenesContainerPath)
	if callBackObj == null:
		callBackObj = get_parent()
	CallBackObj = callBackObj
	
	if is_instance_valid(scenesContainer):
		ScenesContainer = scenesContainer
		if is_instance_valid(ButtonsContainer):
			createButtons(scenesContainer, ButtonsContainer)
			createReturnButton(ButtonsContainer, callBackObj)
		else:
			printerr("DynamicMenu.gd " + self.name + " problem locating button container")
	setTitle()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if BackgroundImage != null:
		var bgTex
		if BackgroundImage.is_class("Image"):
			bgTex = BackgroundImage.ImageTexture.new()
			bgTex.create_from_image(BackgroundImage)
		elif BackgroundImage.is_class("StreamTexture"):
			bgTex = BackgroundImage

		$Control/bgImage.set_texture(bgTex)
	else:
		printerr("Dynamic Menu should have an image set in the inspector.")



func setTitle():
	var labelNode = find_node("MenuTitle")
	if is_instance_valid(labelNode):
		labelNode.set_text(MenuName)
		

func createButtons(scenesContainer, buttonsContainer):
		
	if is_instance_valid(scenesContainer):
		for scene in scenesContainer.get_children():
			if scene != self:
				createButton(scene, buttonsContainer)
		
		
func createReturnButton(buttonsContainer, callBackObj):
		var newButton = Button.new()
		newButton.name = "Return" # not sure if we should escape slashes for this or convert to camel case
		newButton.set_text(newButton.name)
		buttonsContainer.add_child(newButton)
		print("DynamicMenu.gd creating new button: " + newButton.name)
		if callBackObj.has_method("_on_menu_finished"):
			newButton.connect("pressed", callBackObj, "_on_menu_finished")
		else:
			printerr("When adding a dynamic menu, you need an _on_menu_finished function in the callback object to receive it's signal for when a user presses the Back button.")


func createButton(scene, buttonsContainer):
	# create the button and connect the signals
	
	if not is_instance_valid(buttonsContainer):
		buttonsContainer = instantiateNewButtonContainer()
		ButtonsContainer = buttonsContainer
	
	if is_instance_valid(buttonsContainer):
		var newButton = Button.new()
		newButton.name = scene.name # not sure if we should escape slashes for this or convert to camel case
		newButton.set_text(scene.name)
		buttonsContainer.add_child(newButton)
		#print("DynamicMenu.gd creating new button: " + newButton.name)
		newButton.connect("pressed", self, "_on_button_pressed", [newButton.name])


func instantiateNewButtonContainer():
	# instantiate a new vbox and post the buttons
	var panel = PanelContainer.new()
	add_child(panel)
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	return vbox
 
################################################################################
# Signals

func _on_button_pressed(buttonName):
	print("DynamicMenu.gd _on_button_pressed("+ buttonName +") called")
	if ScenesContainer.has_node(buttonName):
		var newScene = ScenesContainer.get_node(buttonName)
		newScene.set_visible(true)
		self.set_visible(false)

		if newScene.has_signal("finished"):
			if not newScene.is_connected("finished", self, "_on_scene_finished"):
				newScene.connect("finished", self, "_on_scene_finished")
		else:
			printerr("Dynamic menu expects all scenes to have a finished function")

		if newScene.has_method("start"):
			newScene.start(CallBackObj)
		else:
			printerr("DynamicMenu.gd: newScene, " + newScene.name + ", requires a 'start' function.")
		

func _on_scene_finished(scene):
	print("Dynamic Menu received _on_scene_finished signal")
	$Camera2D._set_current(true)
	self.set_visible(true)
