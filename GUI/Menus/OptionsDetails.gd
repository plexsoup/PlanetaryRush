extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_faction_colors()
	initializePrompts()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func initializePrompts():
	var numFactionsButton = $VBoxContainer/FactionsSection/NumFactionsContainer/NumFactionsButton
	numFactionsButton.selected = global.NumFactions
	
	var difficultyButton = $VBoxContainer/HSplitContainer/LSide/Options/Difficulty/DifficultyButton
	difficultyButton.selected = global.options["difficulty"]

	var gameSpeedSlider = $VBoxContainer/HSplitContainer/LSide/Options/GameSpeed/SpeedSlider
	gameSpeedSlider.set_value(global.game_speed)

func _on_UI_element_clicked(button_pressed):
	$Sounds/ClickNoise.play()


func _on_UI_slide_element_selected():
	$Sounds/SlideNoise.play()


func _on_SpeedSlider_mouse_entered():
	pass # Replace with function body.


func _on_SpeedSlider_mouse_exited():
	pass # Replace with function body.


func _on_NumFactionsButton_item_selected(index):
	$Sounds/ClickNoise.play()
	global.NumFactions = index + 1
	print("OptionDetails.gd: index == " + str(index) + " therefore NumFactions = " + str(global.NumFactions) )


func set_faction_colors():
	var factionSelectionList = $VBoxContainer/FactionsSection/FactionSelectHSplit/FactionSelect
	for factionNum in (5):
		factionSelectionList.set_item_icon_modulate(factionNum, global.FactionColors[factionNum+1])

func _on_FactionSelect_item_selected(index):
	if index < global.NumFactions:
		$Sounds/ClickNoise.play()
		print(self.name + " selected faction " + str(index+1))
		global.PlayerFactionNum = index+1 # reserve zero for neutral faction
		
