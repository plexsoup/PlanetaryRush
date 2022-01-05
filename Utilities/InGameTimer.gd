extends Timer


# Declare member variables here. Examples:
var DefaultWaitTime : float

# Called when the node enters the scene tree for the first time.
func _ready():
	DefaultWaitTime = self.wait_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_pause_toggled(newState):
	if newState == global.States.PAUSED:
		self.set_paused(true)
	elif newState == global.States.FIGHTING:
		self.set_paused(false)
