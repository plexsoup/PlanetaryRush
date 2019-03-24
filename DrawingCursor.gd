extends Area2D

var MyPath : Path2D

# Called when the node enters the scene tree for the first time.
func _ready():
	MyPath = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if MyPath.State == MyPath.States.DRAWING:
		set_global_position(get_global_mouse_position())
	
