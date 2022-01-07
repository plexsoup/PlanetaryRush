"""
Current Work Effort:

	
- there's still a problem with win/lose signalling
	
- planets lose their population too easily.
	- have the ships go into a bombardment state and work on it a bit more slowly.

- sometimes the AI draws from unowned planets
	- Maybe the Cursor should be a child of the Faction


- move win/lose checks into a referee object?


Bugs
- can't select the yellow faction (or likely any faction > numFactions)

- if you pause, then restart game: all planets spawn at -1 population

- AI doesn't realize they've lost a planet before they finish drawing a line
- lines will draw even if the planet has zero or -1 ships
- AI is paralyzed when there's no gray planets left?
- faction list on title screen is wrong / makes no sense

Refactoring Required
- Pause menu notifies player's cursor about pause/unpause.
	- instead, it should notify Main or Level then let them worry about it.
	- pausemenu.gd shouldn't have to be aware of cursors or players
- Main should instantiate StartScreen and EndScreen as new levels, instead of changing visibility?
	- This will allow us to add an upgrade/shopping scene as well
	- PauseMenu can stay as a hidden node
- OptionsDetails has a ton of little button scripts.. move them into the root of OptionsDetails

- Someday you might have more than one fleet assigned to any given path..
	- which means each fleet needs a PathFollow2D node assigned to a common ShipPath
	- but... PathFollow2D nodes must be children of Path nodes.
	- so each ShipPath might need more than one PathFollow2D node.
	
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
- instructions say flank fleets for advantage, but ships turn so fast in dogfights that flanking provides no benefit.

- claiming planets feels way worse than it did on the original release webgame on itch.io

- planet bombardment feels weak.. add more juice. Player should know when ships are bombing planets

- move game speed slider to main gameplay window

- ships don't feel like they're trying to achieve their objective..
	- when they get to their destination planet, they scatter.
	
- pausing brings up the new game menu.. feels a bit weird.

- fix some of the lag.. maybe get rid of lasers. maybe make fleets one unit instead of a flock of ships

- if the fleet is empty (dead), the path should disappear.
- ships should only move forward.. turn toward desired vector, then go forward.

- need a way to pause the action, but still zoom in and out and look around

Big design ideas.
- would it be cooler if planets had visible ships flying around them (sort of like Arcen games "Last Federation")
- since nav targets have collision areas, should you be able to drag from those and redraw paths for existing fleets?
- should all the line drawing features be available during game pause, so players can treat it more like a turn-based game?
	- if you have that, you could add timed pauses so players can redraw without having to worry about pausing. 

Important Engineering Decisions:
	- Who's responsible for evaluating and announcing win/loss conditions?
	- Right now: when a planet switches sides, it notifies faction.
	- if faction is out of planets, then out of ships, it notifies level
	- level counts remaining factions and triggers the celebration



"""


extends Node


