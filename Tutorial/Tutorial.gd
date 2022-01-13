extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func show_tutorial_stage_selection_menu():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	print("Tutorial.gd: activate()" + str(get_children()))
	$"Stage 1".start()
	
func deactivate():
	#$"Stage 1".end()
	pass
	#can't be queuing free the hand-placed bespoke assets.

func _on_stage_ended(stage):
	show_tutorial_stage_selection_menu()
	# or just: start_next_stage()
	
