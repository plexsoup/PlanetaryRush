extends Control

# Declare member variables here. Examples:
onready var WinBox = $MarginContainer/MarginContainer/VBoxContainer/WinLose/Win
onready var LoseBox = $MarginContainer/MarginContainer/VBoxContainer/WinLose/Lose

signal Restart_pressed
signal Quit_pressed
signal player_requested_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("connect_signals") # wait for Main to be ready
	
func connect_signals():
	connect("Restart_pressed", get_parent(), "_on_Restart_pressed")
	connect("Quit_pressed", get_parent(), "_on_Quit_pressed")
	connect("player_requested_scene", get_parent(), "_on_player_requested_scene")

func win():
	print("endscreen received call to: win()")
	show_win_info()

	var textBox = WinBox.get_node("WinText")
	var playerNames = ["soldier", "general", "commander"]
	var eliminatedNames = ["defeated", "eliminated", "crushed", "conquered"]
	var factionNames = ["enemy threat", "alien menace", "rebel alliance", "interstellar horde", "zombie rednecks", "heretics"]
	var sectorNames = ["galaxy", "sector", "quadrant", "homeworld", "universe"]
	var safetyNames = ["preserved", "protected", "safe again", "safe at last", "under control", "free of threat", "stable"]
	var gratitudeNames = ["Emporer thanks you.", "people celebrate you.", "alliance rejoices.", "federation is pleased."]

	textBox.set_text(
		"Congratulations " + getRandomElement(playerNames) + ", you have " + getRandomElement(eliminatedNames) + " the " + getRandomElement(factionNames) + ". The " + getRandomElement(sectorNames) + " is " + getRandomElement(safetyNames) + ". The " + getRandomElement(gratitudeNames)
	)
	
func lose():
	
	show_lose_info()
	
	var textBox = LoseBox.get_node("LoseText")
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

	
func show_win_info():
	WinBox.show()
	LoseBox.hide()
	
func show_lose_info():
	LoseBox.show()
	WinBox.hide()
	



func _on_Restart_pressed():
	emit_signal("Restart_pressed")
	$ClickNoise.play()

func _on_Quit_pressed():
	$ClickNoise.play()
	yield(get_tree().create_timer(0.2), "timeout")
	emit_signal("Quit_pressed")




func _on_BackToMainMenu_pressed():
	emit_signal("player_requested_scene", "MainMenu")
	$ClickNoise.play()
