extends CheckBox

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_FullscreenCheckbox_toggled(button_pressed):
	OS.set_window_fullscreen(button_pressed)





func _on_MouseConfineCheckbox_toggled(button_pressed):
	if button_pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
