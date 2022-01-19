extends Control

signal opened()
signal closed()
signal quit_pressed()
#signal quickplay_button_pressed()
#signal tutorial_requested()

signal player_requested_scene(sceneName)

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	call_deferred("start") # wait for Cursor to register itself
	
func start():
	connect("player_requested_scene", global.Main, "_on_player_requested_scene")
	yield(get_tree().create_timer(0.2), "timeout")
	show_pause_menu()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func hide_pause_menu():
	hide()
	global.toggle_hard_pause()
	
func show_pause_menu():
	show()
	global.toggle_hard_pause()



func _input(event):
	pass # makes sense to move pause into the Level object instead of global
#	if is_visible() == false and Input.is_action_just_pressed("ui_show_options_menu"):
#		show_pause_menu()
#	elif is_visible() == true and Input.is_action_just_pressed("ui_show_options_menu"):
#		hide_pause_menu()
#	elif Input.is_action_just_pressed("ui_pause_action"):
#		print("user requested a soft pause toggle")
#		global.toggle_soft_pause()
	


func _on_QuitButton_pressed():
	connect("quit_pressed", global.Main, "_on_Quit_pressed")
	emit_signal("quit_pressed")
	disconnect("quit_pressed", global.Main, "_on_Quit_pressed")
	


func _on_QuickPlayButton_pressed():
	emit_signal("player_requested_scene", "QuickPlay")
	$ClickNoise.play()



func _on_RichText_meta_clicked(meta):
	# this is to open webpages for the links in the licenses panel.
	# might not be a good idea.
	OS.shell_open(meta)


func _on_TabContainer_tab_changed(tab):
	$SlideNoise.play()
	


func _on_TutorialButton_pressed():
	$ClickNoise.play()
	emit_signal("player_requested_scene", "Tutorial")


func _on_CreditsButton_pressed():
	$ClickNoise.play()
	emit_signal("player_requested_scene", "Credits")
