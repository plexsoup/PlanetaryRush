extends Control

signal opened()
signal closed()
signal quit_pressed()

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	call_deferred("start") # wait for Cursor to register itself
	
func start():
	yield(get_tree().create_timer(0.2), "timeout")
	show_pause_menu()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func hide_pause_menu():
	hide()
	if global.cursor and global.cursor != null:
		if not is_connected("closed", global.cursor, "_on_pause_menu_closed"):
			connect("closed", global.cursor, "_on_pause_menu_closed")
		emit_signal("closed")
	global.toggle_hard_pause()
	
func show_pause_menu():
	show()
	if global.cursor and global.cursor != null:
		if not is_connected("opened", global.cursor, "_on_pause_menu_opened"):
			connect("opened", global.cursor, "_on_pause_menu_opened")		
		emit_signal("opened")
	global.toggle_hard_pause()



func _input(event):
	if is_visible() == false and Input.is_action_just_pressed("ui_show_options_menu"):
		show_pause_menu()
	elif is_visible() == true and Input.is_action_just_pressed("ui_show_options_menu"):
		hide_pause_menu()
	elif Input.is_action_just_pressed("ui_pause_action"):
		print("user requested a soft pause")
		global.toggle_soft_pause()
	


func _on_QuitButton_pressed():
	connect("quit_pressed", global.Main, "_on_Quit_pressed")
	emit_signal("quit_pressed")
	disconnect("quit_pressed", global.Main, "_on_Quit_pressed")
	


func _on_RestartButton_pressed():
	if global.Main.has_method("restart"):
		
		global.Main.restart()
		hide_pause_menu()
		global.toggle_hard_pause()
		$ClickNoise.play()


func _on_RichText_meta_clicked(meta):
	OS.shell_open(meta)


func _on_TabContainer_tab_changed(tab):
	$SlideNoise.play()
	
