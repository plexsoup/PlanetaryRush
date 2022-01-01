extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
	
	

func _on_UI_element_clicked(button_pressed):
	$ClickNoise.play()




func _on_UI_slide_element_selected():
	$SlideNoise.play()
	


func _on_SpeedSlider_mouse_entered():
	pass # Replace with function body.


func _on_SpeedSlider_mouse_exited():
	pass # Replace with function body.


func _on_NumFactionsButton_item_selected(index):
	$ClickNoise.play()
	global.NumFactions = index + 2
	print("OptionDetails.gd: index == " + str(index) + " therefore NumFactions = " + str(global.NumFactions) )

	global.NeutralFactionNum = global.NumFactions
	global.FactionColors[global.NeutralFactionNum] = Color.gray # this could be a signal instead of changing values directly?

	var factionSelector : ItemList = get_node("VBoxContainer/HSplitContainer2/Faction/FactionSelect")
	for i in range(5):
		if i >= global.NumFactions:
			factionSelector.set_item_disabled(i, true)
		else:
			factionSelector.set_item_disabled(i, false)



