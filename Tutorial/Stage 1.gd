# Stage 1 of the tutorial just has two planets
# one planet belongs to the player, one is neutral.
# text says: draw line from your planet to the neutral planet.
# or something like that.

# so... can we build this stage in the interface, or do we have to code it?
# if we can't build it in the interface, why not? Should we be able to?

# need.. 
# 2 factions (for owning planets)
# 2 planets (for spawning ships)
# 1 cursor (for drawing lines)
# 1 player controller (for mouse events)

# may need some kind of referee to evaluate the win condition?

# Alternatively, you need a factory object, to spawn two factions, two planets.



extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
