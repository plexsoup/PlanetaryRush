extends Node2D
class_name MenuEntry, "res://GUI/icons/theater-curtains.svg"

# Declare member variables here. Examples:
signal level_completed(sceneObj)
signal finished(sceneObj)
export var AnimationName = "DropLogo"


func _ready():
	pass


func start(callBackObj):
	# note: callBackObj is responsible for connecting the signal.
	
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play(AnimationName)
	else:
		printerr("Consider putting an AnimationPlayer node in your scene to handle the entry transition: " + self.name)

	if has_node("Timer"):
		$Timer.start()
	else:
		_on_Timer_timeout()


func launch_menu():
	var menu
	if get_children()[0].is_class("DynamicMenu"):
		menu = get_children()[0]
	else:
		menu = find_node("*Menu")
	print("MenuEntry.gd in launch_menu() found menu: " + str(menu) + " " + menu.name)
	menu.connect("finished", self, "_on_menu_finished")
	menu.start(self)
	menu.show()
	

func end():
	if has_node("AnimationPlayer"):
		$AnimationPlayer.stop()
	emit_signal("finished", self)

################################################################################
# Incoming Signals
func _on_Timer_timeout():
	launch_menu()

func _on_menu_finished():
	end()
