extends Button

signal level_requested(level_path)


func _on_RestartButton_pressed():
	#print(self.name, " restart button pressed." )
	var _err = connect("level_requested", global.main_scene, "_on_level_requested")
	if _err: push_warning(_err)
	emit_signal("level_requested", "res://Levels/InteriorCottageStart.tscn")
	disconnect("level_requested", global.main_scene, "_on_level_requested")
