"""
Current Work Effort:
- figure out how to pause the game on startup.. need to pause the AI in particular
- set the starting planets further apart, if possible



Bugs

- AI planets sometimes go below 1. (I've seen 0 or -1)

- Camera offset (keyboard) isn't working well with camera mouse drag.
- AI ships don't get released or land. They just fly around the destination planet.

- AI is paralyzed when there's no gray planets left


Features to add

- change ship lasers.. they're too costly
	- if something enteres your forward firing arc, draw a line to it and inflict damage.

- change the AI fleet spawning to create a path first, then send that instead of a destination planet.AABB
	- make the AI play by the same rules as the player.
	
- add a bombardment phase, when a ship is near the planet.



Game Feel Enhancements to change
- move game speed slider to main gameplay window

- pausing brings up the new game menu.. feels a bit weird.

- fix some of the lag.. maybe get rid of lasers. maybe make fleets one unit instead of a flock of ships

- if the fleet is empty (dead), the path should disappear.
- ships should only move forward.. turn toward desired vector, then go forward.

- need a way to pause the action, but still zoom in and out and look around



"""


extends Node


