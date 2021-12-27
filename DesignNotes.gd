"""

Bugs

- I've seen ships fly off in random directions now and then.
- Camera offset (keyboard) isn't working well with camera mouse drag.
- Ships wiggle a lot


- AI is paralyzed when there's no gray planets left


Features to add

- change ship lasers.. they're too costly
	- if something enteres your forward firing arc, draw a line to it and inflict damage.



Game Feel Enhancements to change
- move game speed slider to main gameplay window

- pausing brings up the new game menu.. feels a bit weird.

- fix some of the lag.. maybe get rid of lasers. maybe make fleets one unit instead of a flock of ships

- if the fleet is empty (dead), the path should disappear.
- ships should only move forward.. turn toward desired vector, then go forward.

- need a way to pause the action, but still zoom in and out and look around



"""


extends Node


