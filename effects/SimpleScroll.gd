# for putting very basic scrolling behaviour on sprites
# useful for title screens and endscreens, to have ships scroll past.

# uses local transforms, so if the parent node has a scale, the scroll speed will be faster or slower relative to other parent nodes.
# (kinda like cheap versions of parallax backgrounds, which won't work for us because they can't be hidden.)

extends Sprite


# Declare member variables here. Examples:

export var ScrollRate: Vector2 = Vector2(-50.0, 0.0)

var SpeedFuzz = 0.1 # percentage to adjust speed randomly plus or minus

# Called when the node enters the scene tree for the first time.
func _ready():
	adjustScrollRate()
	
func adjustScrollRate():
	ScrollRate = ScrollRate * (1.0 + rand_range(-SpeedFuzz, SpeedFuzz))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(ScrollRate * delta )



	 
