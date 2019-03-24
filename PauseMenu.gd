extends Control

signal opened()
signal closed()


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
	if not is_connected("closed", global.cursor, "_on_pause_menu_closed"):
		connect("closed", global.cursor, "_on_pause_menu_closed")
	emit_signal("closed")
	global.unpause()
	
func show_pause_menu():
	show()
	if not is_connected("opened", global.cursor, "_on_pause_menu_opened"):
		connect("opened", global.cursor, "_on_pause_menu_opened")		
	emit_signal("opened")
	global.pause()



func _input(event):
	if is_visible() == false and Input.is_action_just_pressed("ui_cancel"):
		show_pause_menu()
	elif is_visible() == true and Input.is_action_just_pressed("ui_cancel"):
		hide_pause_menu()
		


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_RestartButton_pressed():
	if global.Main.has_method("restart"):
		global.Main.restart()
		hide_pause_menu()


func _on_RichText_meta_clicked(meta):
	OS.shell_open(meta)
