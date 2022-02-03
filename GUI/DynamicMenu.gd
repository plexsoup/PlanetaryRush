extends Node2D

class_name DynamicMenu, "res://GUI/icons/open-book-g.svg"

# Place this node inside a node, with siblings for each button item

export var ScenesContainerPath : String = ""
export var MenuName : String = "Dynamic Menu"
export var BackgroundImage : Texture
export var ShowReturnButton: bool = true

var ButtonsContainerPath : String = "Control/bgImage/CenterContainer/PanelContainer/VBoxContainer"
var MenuTitleLabelPath = "Control/bgImage/CenterContainer/PanelContainer/VBoxContainer/MenuTitle"
var ScenesContainer : Node
var ButtonsContainer : VBoxContainer

var CallBackObj : Node # who to tell when we're done or when a scene completes or whatever


signal finished() # when user presses the return button to go up one level

func start(callBackObj : Node = null):
	setTitle(MenuName)
	

	
	if verifyContainers() == false:
		printerr("Problem in DynamicMenu.gd on " + self.name + " ButtonContainerPath or ScenesContainerPath are incorrect")
		return
	else:
		ScenesContainer = get_node(ScenesContainerPath)
		ButtonsContainer = get_node(ButtonsContainerPath)

	hide_all_scenes(ScenesContainer)
	cleanup_old_buttons()
		
	if callBackObj == null:
		callBackObj = get_parent()
	CallBackObj = callBackObj
	
	if is_instance_valid(ButtonsContainer):
		createButtons(ScenesContainer, ButtonsContainer)
		if ShowReturnButton:
			createReturnButton(ButtonsContainer, callBackObj)
	else:
		printerr("DynamicMenu.gd " + self.name + " problem locating button container")

	self.show()

	
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

	if ScenesContainerPath != "":
		ScenesContainer = get_node(ScenesContainerPath)
		if is_instance_valid(ScenesContainer):
			hide_all_scenes(ScenesContainer)

func cleanup_old_buttons():
	# script was creating endless buttons. easy fix is to free old buttons
	if ButtonsContainer.get_child_count() > 1: # allowed to have a label
		for button in ButtonsContainer.get_children():
			if button.is_class("Button"):
				button.call_deferred("queue_free")
	

func verifyContainers():
	var valid : bool = false # until proven otherwise
	if has_node(ScenesContainerPath) and is_instance_valid(get_node(ScenesContainerPath)):
		if has_node(ButtonsContainerPath) and is_instance_valid(get_node(ButtonsContainerPath)):
			valid = true
	return valid
	

func hide_all_scenes(scenesContainer):
	for scene in scenesContainer.get_children():
		# hide menu effects or whatever else we put in the menu
		if scene != scenesContainer:
			if scene.has_method("hide"):
				scene.hide()
			else:
				printerr("DynamicMenu.gd encountered a scene ("+ scene.name +") which can't be hidden in " + self.name)

func setTitle(titleString):
	var labelNode = find_node("MenuTitle")
	if is_instance_valid(labelNode):
		labelNode.set_text(titleString)
		

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
		if callBackObj.has_method("_on_menu_finished"):
			newButton.connect("pressed", callBackObj, "_on_menu_finished", [self])
		else:
			printerr("When adding a dynamic menu, you need an _on_menu_finished function in the callback object to receive it's signal for when a user presses the Back button.")


func createButton(scene, buttonsContainer):
	# create the button and connect the signals
	
	if not is_instance_valid(buttonsContainer):
		buttonsContainer = instantiateNewButtonContainer()
		ButtonsContainer = buttonsContainer
	else:
		pass # buttonsContainer is already good
	
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

func launchScene(sceneName):
	hide_all_scenes(ScenesContainer)
	$Control.hide()
	if ScenesContainer.has_node(sceneName):
		var newScene = ScenesContainer.get_node(sceneName)
		newScene.set_visible(true)
		self.set_visible(false)

		if newScene.has_signal("finished"):
			if not newScene.is_connected("finished", self, "_on_scene_finished"):
				newScene.connect("finished", self, "_on_scene_finished")
		else:
			printerr("Dynamic menu expects all scenes to have a finished function")

		if newScene.has_method("start"):
			#newScene.start(CallBackObj)
			newScene.start(self)
			
		else:
			printerr("DynamicMenu.gd: newScene, " + newScene.name + ", requires a 'start' function.")
	else:
		printerr("DynamicMenu.gd Scenes container doesn't have a scene matching name: " + sceneName)


 
################################################################################
# Signals

func _on_button_pressed(buttonName):
	print("DynamicMenu.gd _on_button_pressed("+ buttonName +") called")
	launchScene(buttonName)


func _on_scene_finished(scene):
	print("Dynamic Menu received signal _on_scene_finished for " + scene.name)
	print("CallbackObj is " + CallBackObj.name)
	
	scene.hide()
	$Control.show()
	
	$Camera2D._set_current(true)
	self.set_visible(true)
	if scene.name == CallBackObj.name:
		emit_signal("finished", self)

func _on_menu_finished(scene):
	self.hide()
	emit_signal("finished", self) # to CallbackObj
