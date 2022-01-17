"""
Hack to hide all the children of a Canvas Layer whenever
	the parent of the CanvasLayer is hidden.
Useful if you have a lot of canvas layers you want to show/hide,
 	since the base CanvasLayer class doesn't have show/hide functions.
"""
extends CanvasLayer



# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect("visibility_changed", self, "_on_parent_visibility_changed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func hide():
	for element in get_children():
		element.hide()
		print("hiding canvaslayers")

func show():
	for element in get_children():
		element.show()

func set_visible(visible):
	for element in get_children():
		set_visible(visible)





func _on_parent_visibility_changed():
	if get_parent().is_visible_in_tree():
		show()
	else:
		hide()

