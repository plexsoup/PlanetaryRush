extends CheckBox

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_FullscreenCheckbox_toggled(button_pressed):
	OS.set_window_fullscreen(button_pressed)
