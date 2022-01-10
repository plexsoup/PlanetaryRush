extends Node2D


# Declare member variables here. Examples:
var FactionObj
signal click_mouse(position)
var lerp_toward_mouse_speed : float = 0.8 # Not higher than 1!

# Called when the node enters the scene tree for the first time.
func _ready():
	check_requirements()
	FactionObj = get_parent().FactionObj
	

func start(): # typically called by the parent once the node is in the scene.
	pass

func check_requirements():
	if lerp_toward_mouse_speed > 0.9:
		printerr("In " + self.name + ", lerp_toward_mouse_speed should be 0.0-1.0")

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if get_parent().State == get_parent().States.ACTIVE and get_parent().is_inside_margins():
		get_parent().set_global_position(lerp(get_global_position(), get_global_mouse_position(), lerp_toward_mouse_speed))
	
	
	

func _input(event):
	if Input.is_action_just_pressed("left_click") and is_instance_valid(FactionObj):
		if FactionObj.IsLocalHumanPlayer:
			#signal the parent that we clicked.
			connect("click_mouse", get_parent(), "_on_PlayerController_Clicked")
			emit_signal("click_mouse")
			disconnect("click_mouse", get_parent(), "_on_PlayerController_Clicked")

func isStillDrawing():
	if Input.is_action_pressed("left_click"):
		return true
	else:
		return false

