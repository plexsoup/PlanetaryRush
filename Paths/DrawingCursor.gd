# Not sure why we need a drawing cursor following the mouse cursor around, but whatever.
extends Area2D

var MyPath : Path2D

# Called when the node enters the scene tree for the first time.
func _ready():
	print("DrawingCursor.gd called by " + self.name + " in " + self.get_parent().name)
	MyPath = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if MyPath.State == MyPath.States.DRAWING:
		set_global_position(MyPath.CursorObj.get_global_position())

