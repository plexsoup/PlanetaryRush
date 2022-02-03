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
		var animPlayer = $AnimationPlayer
		animPlayer.play(AnimationName)
		if not animPlayer.is_connected("animation_finished", self, "_on_animation_finished"):
			animPlayer.connect("animation_finished", self, "_on_animation_finished")
	elif not has_node("AnimationPlayer"):
		printerr("Consider putting an AnimationPlayer node in your scene to handle the entry transition: " + self.name)

		if has_node("Timer"):
			$Timer.start() # hmm. why not use a signal from AnimationPlayer instead?
		else:
			launch_menu() # no animationPlayer or Timer? Just launch the damn menu.




func launch_menu():
	var menu
	if get_children()[0].is_class("DynamicMenu"):
		menu = get_children()[0]
	else:
		menu = find_node("*Menu")
	print("MenuEntry.gd in launch_menu() found menu: " + str(menu) + " " + menu.name)
	
	if menu.has_signal("finished") and not menu.is_connected("finished", self, "_on_menu_finished"):
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

func _on_animation_finished(animationName):
	print("MenuEntry.gd: Animation Finished: " + animationName)
	if animationName == "Enter":
		launch_menu()
	elif animationName == "Exit":
		end()

func _on_menu_finished(sceneFinishing):
	if has_node("AnimationPlayer") and $AnimationPlayer.has_animation("exit"):
		$AnimationPlayer.play("exit")

	else:
		end()
