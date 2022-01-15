"""
Current Work Effort:

- actioncamera gets really squashed/stretched sometimes.

- bug: if you play through the tutorial, there's a nonexistent function "get_referee" in base Nil error after switching stages.

- seems like we need more cleanup after a level has ended.. ships are committing suicide after a time limit because they weren't garbage collected.

- add a button to the tutorial menu to go back to main.
	- or, add a routine in DynamicMenu to always add an UP button

- move global.PlayerFaction into Level.gd


- build the blueprint import system for level design
	- clone each planet
	- identify all the factionNumbers on planets
	- spawn factions as required
	- hide the blueprint
	- launch the level

- figure out how to set the camera zoom so it includes all the planets

- move the pause function from global.gd into Level.gd
	- game_speed can live there too, cause it's really speed for the current level

- sometimes (rarely) the player doesn't get a starting planet?

- sometimes it feels like you should acquire a planet, but you don't get it.
	- 2 ships vs population of 1
	- it may be the production timer working against you.
	

- quickplay doesn't end when player loses all planets
- or when you win all planets

- it's not obvious what colour you are when you start quickplay.



modify factions a bit.
- neutral is faction == null
- planets with no faction are neutral
- revise the faction object, now all factions will have cursors.
	- each cursor gets a controller.
	- you can save one as a player, and another as AI
	- then you don't have to spawn the controller in code.
	- can use a bespoke flag if you want


- figure out how to start the tutorial with 2 planets

	
- Make objects work independently from parents and grandparents
	- To craft a tutorial, you have to be able to place planets and factions, etc.

- Level.gd assumes all kinds of folder structure.. planets in planets, etc.
	- figure out how to make level script coexist with hand-crafted levels
	


- when we have campaigns, it won't make sense for level to signal main that the player won or lost..
	- the campaign object will need to handle that.
	- main can still handle it for quickplay games though?
	

- AI doesn't know it's won after the player is dead.
- AI sometimes quits before it lost
	- might need a referee object still. To wake up dead AI or kill losers
- AI sometimes stops planning routes once the player is dead.

- there's a big flaw in fleet engagement: once a fleet has been released from it's path, it no longer has a dogfightzone collision area, so other ships can't engage it.
	- revisit the bombardment State
	
- there may still be a problem with win/loss signalling
	- I just had a win when another faction was still alive.

- dogfights feel bad

- planetary bombardment feels bad

- camera feels bad
	- maybe you wnat to move the camera off the player controller, so it doesn't follow the mouse around.
	- put it back on level
	
- strategy is weird.. AI loses easily because they don't consider the strength of the planet they're attacking.
	- they might need coordinated strategy, where they plan a few moves ahead.

- if a faction loses a planet while they're still draing the path, the path freezes.
	- it should be released instead. Or something.

- if a faction loses all their planets while a fleet is in transit, the paths remain
	- someone's not receiving a notification that all ships are gone


- Feels weird how ships explode when they claim a planet.

- planets lose their population too easily.
	- have the ships go into a bombardment state and work on it a bit more slowly.

- sometimes the AI draws from unowned planets
	- Maybe the Cursor should be a child of the Faction


- move win/lose checks into a referee object?


Bugs
- restarting the game doesn't remove the previous game instance.
	- need a routine in level.end() to empty the planets, factions, etc.

- pauses no longer work. After moving title card scenes around.
	- pause/unpause is probably due for a refactor
- after restarting the game, the planet fonts are really small.




- every other hard pause, the camera zoom fails to work.

- in multiplayer games, one of the AI will eventually get stuck with a path that won't release.
	- possibly after their ships died due to fuel loss?

- can't select the yellow faction (or likely any faction > numFactions)

- if you pause, then restart game: all planets spawn at -1 population

- AI doesn't realize they've lost a planet before they finish drawing a line
- lines will draw even if the planet has zero or -1 ships
- AI is paralyzed when there's no gray planets left?
- faction list on title screen is wrong / makes no sense

Refactoring Required
- make a Factions script, analogous to our Planets script.
	- it can handle spawning and ending factions, finding, counting, etc.
	- might be useful to talk to the referee about remaining factions

- consider adding setget to the State variables everywhere.
	- when state changes, maybe someone should be notified.
	https://docs.godotengine.org/en/3.0/getting_started/scripting/gdscript/gdscript_basics.html?highlight=setget#setters-getters
	
- Right now a lot of objects rely on Level (eg: to ask planetcontainer for nearest planet)
	- We pass levelObj to any objects that need it, but that means objects won't work if they aren't instantiated by code.
	- figure out if we can move currentlevel back to global, so we can get handcrafted levels to work.

- Maybe each weapon should have it's own firing collision area node, then it can manage firing itself.
	- would allow you to have more than one kind of weapon
	- which means you can have a shop with upgrades.

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
- cursor should scale like a brush in photoshop, changing the influence area.
	- with a big influence area, player could send fleets from multiple planets on one path.
	- path arrows could be sized based on the cursor size at the time.

Important Engineering Decisions:
	- Who's responsible for evaluating and announcing win/loss conditions?
	- Right now: when a planet switches sides, it notifies faction.
	- if faction is out of planets, then out of ships, it notifies level
	- level counts remaining factions and triggers the celebration


Long Term: 'Maybe Someday' Stuff
- Will you provide multiplayer support? 
	- If so, all the global.PlayerFactionObj references might fail.
- Do you want it to be modable? 
	- If so, sprites need to be loaded dynamically from a folder and properties need to come from json files.
	- https://docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_pcks.html#overview-of-pck-files
	



"""


extends Node


