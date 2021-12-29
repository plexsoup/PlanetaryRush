extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	print("MoveLabel ready. " + self.name + ", " + get_parent().name)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		position.x += 10
	elif Input.is_action_just_pressed("ui_right"):
		position.x -= 10

