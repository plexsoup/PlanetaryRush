"""
Current Work Effort:
- planets lose their population too easily.
	- have the ships go into a bombardment state and work on it a bit more slowly.

- set a destination planet on the fleet's path
	- avoid all other planets on the way to destination
	

- sometimes the AI draws from unowned planets
	- Maybe the Cursor should be a child of the Faction


- set the starting planets further apart, if possible

- find all the timers and make sure they respect game speed.
	- add to group InGameTimers
	- walk through the group and adjust as required
	- consider a custom timer object (if required)
	- you might need a signals bus for this.. so you can subscribe to game_speed changed events.

- move win/lose checks into a referee object?


Bugs
- planets spawn on top of each other
- AI draw lines through planets
- ships should avoid planets

- If player selects any other factions, game freaks out.
- global.toggle_soft_pause needs a way to restart timers after a pause.
- AI doesn't realize they've lost a planet before they finish drawing a line
- lines will draw even if the planet has zero or -1 ships
- AI is paralyzed when there's no gray planets left?
- faction list on title screen is wrong / makes no sense

Refactoring Required
- Main should instantiate StartScreen and EndScreen as new levels, instead of changing visibility?
	- This will allow us to add an upgrade/shopping scene as well
	- PauseMenu can stay as a hidden node
- OptionsDetails has a ton of little button scripts.. move them into the root of OptionsDetails

Features to add

- consider having the gamespeed slowly increase over time. reduces some of the late-stage grind other 4x games have
- change ship lasers.. loading them is too costly
	- if something enteres your forward firing arc, draw a line to it and inflict damage.
	- or keep a pool of pre-spawned lasers and recycle them.
- dogfights should be more interesting / sustained. Have the fleet pause to deal with the threat.
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



Important Engineering Decisions:
	- Who's responsible for evaluating and announcing win/loss conditions?
	- Right now: when a planet switches sides, it notifies faction.
	- if faction is out of planets, then out of ships, it notifies level
	- level counts remaining factions and triggers the celebration



"""


extends Node


