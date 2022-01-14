extends Node2D
# Place this node inside a node, with siblings for each button item

export var ScenesContainerPath : String = ""
export var ButtonsContainerPath : String = "Control/bgImage/CenterContainer/PanelContainer/VBoxContainer/Label"
export var MenuName : String = "Dynamic Menu"

var ScenesContainer : Node
var ButtonsContainer : Control
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func start(scenesContainer : Node = null):
	if scenesContainer == null:
		scenesContainer = get_node(ScenesContainerPath)
		
	if is_instance_valid(scenesContainer):
		ScenesContainer = scenesContainer
		
		ButtonsContainer = get_node(ButtonsContainerPath)
		if is_instance_valid(ButtonsContainer):
			createButtons(scenesContainer, ButtonsContainer)
		else:
			printerr("DynamicMenu.gd " + self.name + " problem locating button container")
	setTitle()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setTitle():
	var labelNode = find_node("MenuTitle")
	if is_instance_valid(labelNode):
		labelNode.set_text(MenuName)
		

func createButtons(scenesContainer, buttonsContainer):
		
	if is_instance_valid(scenesContainer):
		for scene in scenesContainer.get_children():
			if scene != self:
				createButton(scene, buttonsContainer)


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
		print("DynamicMenu.gd creating new button: " + newButton.name)
		newButton.connect("pressed", self, "_on_button_pressed", [newButton.name])


func instantiateNewButtonContainer():
	# instantiate a new vbox and post the buttons
	var panel = PanelContainer.new()
	add_child(panel)
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	return vbox
 

func _on_button_pressed(buttonName):
	print("DynamicMenu.gd _on_button_pressed("+ buttonName +") called")
	if ScenesContainer.has_node(buttonName):
		var newScene = ScenesContainer.get_node(buttonName)
		newScene.set_visible(true)
		self.set_visible(false)

		if newScene.has_method("start"):
			newScene.start()
		else:
			printerr("DynamicMenu.gd: newScene, " + newScene.name + ", has no start() function.")
	
