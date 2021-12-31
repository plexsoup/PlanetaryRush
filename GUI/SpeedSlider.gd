extends HSlider

# Declare member variables here. Examples:
enum States { FOCUSED, IDLE }
var State = States.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if Input.is_action_just_pressed("left_click") and State == States.FOCUSED:
		start_tone()

	if Input.is_action_just_released("left_click") and State == States.FOCUSED:
		stop_tone()

func start_tone():
	$ToneNoise.play()

func stop_tone():
	$ToneNoise.stop()

func _on_SpeedSlider_value_changed(value):
	global.game_speed = value
	$ToneNoise.set_pitch_scale(value+0.1)
	#update all the timers in the game
	global.Main.updateInGameTimers(value)
		
		


func _on_SpeedSlider_mouse_entered():
	State = States.FOCUSED
	


func _on_SpeedSlider_mouse_exited():
	State = States.IDLE
	stop_tone()



func _on_SpeedSlider_visibility_changed():
	set_value(global.game_speed)
	
