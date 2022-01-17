extends Node2D


# Declare member variables here. Examples:
var FactionObj
var Level
var CursorObj

signal click_mouse(position)
var lerp_toward_mouse_speed : float = 0.8 # Not higher than 1!

# Called when the node enters the scene tree for the first time.
func _ready():
	check_requirements()
	

func start(levelObj, factionObj): # called by Cursor.gd
	Level = levelObj
	FactionObj = factionObj
	CursorObj = get_parent()

func check_requirements():
	if lerp_toward_mouse_speed > 0.9:
		printerr("In " + self.name + ", lerp_toward_mouse_speed should be 0.0-1.0")

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if CursorObj.State == CursorObj.States.ACTIVE and CursorObj.is_inside_margins():
		CursorObj.set_global_position(lerp(get_global_position(), get_global_mouse_position(), lerp_toward_mouse_speed))
	
	
	

func _input(event):
	if Input.is_action_just_pressed("left_click") and is_instance_valid(FactionObj):
		if FactionObj.IsLocalHumanPlayer:
			#signal the parent that we clicked.
			connect("click_mouse", CursorObj, "_on_PlayerController_Clicked")
			emit_signal("click_mouse")
			disconnect("click_mouse", CursorObj, "_on_PlayerController_Clicked")

	elif Input.is_action_just_pressed("ui_pause_action"):
		print("user requested a soft pause toggle")
		Level.toggle_soft_pause()


func isStillDrawing():
	if Input.is_action_pressed("left_click"):
		return true
	else:
		return false

