"""
Load a level
Unload a level
Show an option screen

"""

extends Node2D

var CurrentLevel : Node2D
var levels: Array = ["res://Level.tscn"]

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level(levels[0])
	randomize()
	global.Main = self
	hide_end_screen()

func hide_end_screen():
	get_node("CanvasLayer/EndScreen").hide()

func load_level(level_path):
	var level_scene = load(level_path)
	var newLevel = level_scene.instance()
	add_child(newLevel)
	#newLevel.start()
	CurrentLevel = newLevel
	
func remove_level():
	if CurrentLevel.has_method("end"):
		CurrentLevel.end()
	else:
		CurrentLevel.queue_free()
	
func restart():
	remove_level()
	load_level(levels[0])

func _on_faction_lost(faction):
	var endScreen = get_node("CanvasLayer/EndScreen")
	var titles = get_node("CanvasLayer/EndScreen/MarginContainer/Panel/VBoxContainer/CenterContainer")
	endScreen.show()
	global.pause()
	
	if faction == global.PlayerFaction:
		lose()
	else:
		win()


func lose():
	var endScreen = get_node("CanvasLayer/EndScreen")
	var titles = get_node("CanvasLayer/EndScreen/MarginContainer/Panel/VBoxContainer/CenterContainer")

	# you lose
	titles.get_node("Win").hide()
	titles.get_node("Lose").show()

	var textBox = titles.get_node("Lose/LoseText")
	var playerNames = ["soldier", "general", "commander"]
	var eliminatedNames = ["defeated", "eliminated", "crushed", "conquered"]
	var factionNames = ["enemy threat has", "alien menace has", "rebel alliance have", "interstellar horde have", "zombie rednecks have", "heretics have"]
	var sectorNames = ["galaxy", "sector", "quadrant", "homeland", "universe"]
	var safetyNames = ["preserved", "protected", "safe again", "safe at last", "under control", "free of threat", "stable"]
	var gratitudeNames = ["Emporer will have your head.", "people curse your name.", "alliance mourns.", "federation is disappointed."]

	textBox.set_text(
		"You failed, " + getRandomElement(playerNames) + ". The " + getRandomElement(factionNames) + " " + getRandomElement(eliminatedNames) + " the " + getRandomElement(sectorNames) + ". The " + getRandomElement(gratitudeNames)
	)


func getRandomElement(textArray):
	return textArray[randi()%textArray.size()]
	
func win():
	var endScreen = get_node("CanvasLayer/EndScreen")
	var titles = get_node("CanvasLayer/EndScreen/MarginContainer/Panel/VBoxContainer/CenterContainer")

	# you win
	titles.get_node("Win").show()
	titles.get_node("Lose").hide()

	var textBox = titles.get_node("Win/WinText")
	var playerNames = ["soldier", "general", "commander"]
	var eliminatedNames = ["defeated", "eliminated", "crushed", "conquered"]
	var factionNames = ["enemy threat", "alien menace", "rebel alliance", "interstellar horde", "zombie rednecks", "heretics"]
	var sectorNames = ["galaxy", "sector", "quadrant", "homeworld", "universe"]
	var safetyNames = ["preserved", "protected", "safe again", "safe at last", "under control", "free of threat", "stable"]
	var gratitudeNames = ["Emporer thanks you.", "people celebrate you.", "alliance rejoices.", "federation is pleased."]

	textBox.set_text(
		"Congratulations " + getRandomElement(playerNames) + ", you have " + getRandomElement(eliminatedNames) + " the " + getRandomElement(factionNames) + ". The " + getRandomElement(sectorNames) + " is " + getRandomElement(safetyNames) + ". The " + getRandomElement(gratitudeNames)
	)
	
	


func _on_Quit_pressed():
	$AudioStreamPlayer.stop()
	remove_level()
	$CanvasLayer/PauseMenu.hide()
	$CanvasLayer/EndScreen.hide()
	get_tree().quit()


func _on_Restart_pressed():
	if global.Main.has_method("restart"):
		global.Main.restart()
		$CanvasLayer/EndScreen.hide()
		global.unpause()
		