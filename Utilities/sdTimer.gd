extends Timer
# Purpose: Create a timer which respects the global.game_speed variable
# if game_speed is 0.0, the timer should pause altogether, otherwise, speed up or slow down as appropriate

# Requirements and Dependencies:
# Expects: global.gd with a game_speed var
# Expects a signal_bus so it can add itself to the member list for this type of signal

# Assumptions:
# "normal" game_speed is 1.0. "fast" is 2.0, 0.0 is paused.

# API / exposed functions / signals:
# TBD

# Declare member variables here. Examples:
var Game_Speed
var Previous_Game_Speed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_wait_time()
	

func _on_global_speed_changed(newSpeed):
	# update time_left, wait_time and is_stopped

	Previous_Game_Speed = Game_Speed
	Game_Speed = newSpeed
	update_wait_time(newSpeed)
	
