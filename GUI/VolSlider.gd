extends HSlider

export var bus : int = 0
enum States { IDLE, FOCUSED }
var State = States.IDLE


func _ready():

	# creating the signal connection in code, because its too easy to have bugs from
	# inspector signals that didn't get hooked up right.
	var _err = connect("value_changed", self, "_on_VolSlider_value_changed")
	if _err: push_warning(_err)

func _input(event):
	if event.is_action_pressed("left_click") and State == States.FOCUSED:
		start_SFX()

func start_SFX():
	$pewpewNoise.play()
	$Timer.start()

func stop_SFX():
	$pewpewNoise.stop()
	$Timer.stop()

func _on_VolSlider_value_changed(value):
	AudioServer.set_bus_volume_db(bus, value)

func _on_SoundFxVolSlider_mouse_entered():
	State = States.FOCUSED


func _on_SoundFxVolSlider_mouse_exited():
	State = States.IDLE
	stop_SFX()

func _on_Timer_timeout():
	if State == States.FOCUSED:
		start_SFX()


func _on_SoundFxVolSlider_visibility_changed():
	set_value(AudioServer.get_bus_volume_db(bus))
