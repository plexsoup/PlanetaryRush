
extends Node

var DetailTextBox
var BuglistTreeObj

func _ready():
	start()

func start():
	var bugList = Bugs()
	
	var treeDict = {
		"Current Effort" : Current_Work_Effort(),
		"Bugs" : Bugs(),
		"Refactoring" : Refactoring_Required(),
		"QC Testing Required" : QC(),
		"Features to Add" : Features_to_Add(),
		"Game Feel" : Game_Feel(),
		"Design" : Design(),
		"Hard Design Problems" : Hard_Design_Problems(),
		"Engineering" : Engineering(),
		"Maybe Someday" : Maybe_Someday(),
	
	}
	
	#make_pretty_buttons(bugList.keys())
	var tree = make_pretty_tree(treeDict)
	

func make_pretty_tree(buglistDictionary):
	var marginBox = MarginContainer.new()
	marginBox.set_name("MarginBox")
	marginBox.margin_left = 10
	marginBox.margin_right = get_viewport().size.x
	marginBox.margin_bottom = get_viewport().size.y
	marginBox.anchor_left = 1
	marginBox.anchor_right = 1
	self.add_child(marginBox)
	var tree = Tree.new()
	tree.set_name("Tree")
	tree.set_columns(2)
	tree.set_column_expand(0,false)
	tree.set_column_min_width(0, 200)
	
	tree.set_column_expand(1,true)
	
	marginBox.add_child(tree)
	BuglistTreeObj = tree
	var root = tree.create_item()
	
	for buglistSubDict in buglistDictionary:
		populate_branch(tree, tree.get_root(), buglistSubDict, buglistDictionary[buglistSubDict])
		


	
func populate_branch(treeObj, currentTreeItemNode, branchName, branchContents):
	
	var newBranchNode = treeObj.create_item(currentTreeItemNode)
	newBranchNode.set_text(0, branchName)
	print(branchContents)
	for key in branchContents.keys():
		var itemObj = treeObj.create_item(newBranchNode)
		itemObj.set_text(0, key)
		itemObj.set_text(1, branchContents[key])
		
#	for itemStr in list:
#		var itemObj = tree.create_item(root)
#		itemObj.set_text(0, itemStr)


	
func make_pretty_buttons(list):
	
	var hbox = HBoxContainer.new()
	add_child(hbox)
	hbox.set_owner(get_tree().edited_scene_root)
	
	var leftSide = MarginContainer.new()
	leftSide.set_owner(get_tree().edited_scene_root)
	var rightSide = MarginContainer.new()
	rightSide.set_owner(get_tree().edited_scene_root)
	hbox.add_child(leftSide)
	hbox.add_child(rightSide)
	
	var vbox = VBoxContainer.new()
	leftSide.add_child(vbox)
	
	var detailBox = Label.new()
	rightSide.add_child(detailBox)
	DetailTextBox = detailBox
	DetailTextBox.set_text("Hi")
	
	for item in list:
		var button = Button.new()
		button.set_text(item)
		vbox.add_child(button)
		button.set_owner(get_tree().edited_scene_root)
		button.connect("pressed", self, "_on_button_pressed", [button.get_text()])

func _on_button_pressed(args):
	DetailTextBox.set_text(Bugs()[args])

func Current_Work_Effort():
	var currentWorkEffort = {
		"clean main scene tree" : "figure out which scenes need to be visible/hidden. Ensure that happens in code",
		"remove level obj" : "instantiate levels in code instead of in the inspector",
		"fix actioncamera" : "actioncamera gets stretched/squashed and sometimes zooms wrong",
		"cleanup" : "on ending a level, all objects should get cleaned up, including referee, etc.",
		"refactor playerfaction" : "move global.PlayerFaction into Level.gd",
		"refactor pause" : "move the pause function from global.gd into Level.gd. game_speed as well",
		"gamefeel planet aquisition" : "sometimes it feels like you deserve a planet, but you don't get it (reduced population to zero)",
		"communication" : "- it's not obvious what colour you are when you start quickplay.",
		"buglist" : "do we really need an integrated buglist editor???",
		

	}
	
	return currentWorkEffort

################################################################################

func Bugs():
	pass
	
	var Bugs = {
		
		"restarting": "doesn't remove previous level instance. need more cleanup",
		"pausing" : "pausing should show the options menu",
		"actionCamera viewport" : "actioncamera viewport is squashed/stretched",
		"abandoned paths" : "sometimes a path will fail to queue_free",

	}

	return Bugs

################################################################################

func QC():
	
	var testingRequired = {
		"Indecisive AI" : "After neutral planets are gone, AI sometimes freezes",
		"Faction List on Main Menu" : "Do we still have factions presented in the options menu?",
		"missing start planet" : "Sometimes the player doesn't get a starting planet?",
		"abandoned paths" : "- AI sometimes stops planning routes once the player is dead.",
	}
	
	return testingRequired

################################################################################

func Refactoring_Required():
	var refactor = {
		"faction(S)" : "make a factions container script, similar to planets",
		"setState" : "move State = States.ACTIVE to setState(States.ACTIVE)",
		"weapons" : "move weapon firingArc collisionArea2D out of ship.gd and into the weapons themselves",
		"pause" : "figure out who receives pause signals. who should get them?",
		"level spawning" : "instantiate level.tscn in code instead of in inspector",
		"options menu" : "needs an overhaul",
		"multiple fleets per path" : "might need to instantiate multiple pathfollow2d nodes on each path",
		"bullets" : "still rely on global.BulletContainer. Move that to Level",
		"inGameTimer" : "still relies on global.State rather than Level.State",
	}
	
	return refactor

################################################################################

func Features_to_Add():
	var requiredFeatures : Dictionary = {
		"game_speed acceleration" : "reduce late-game grind by increasing game_speed over time",
		"dogfights" : "could be more interesting.",
		"curved AI paths" : "let the AI create curvy paths, just like the player",
		"campaign" : "need a campaign with levels, currency, upgrades, etc."
	}
	return requiredFeatures

################################################################################

func Game_Feel():
	var gameFeel : Dictionary = {
		"flanking" : "instructions say flank: flanking should confer more advantage",
		"acquiring planets" : "sometimes you don't claim a planet when you feel like you should.",
		"bombardment" : "feels weak. Needs more juice",
		"game_speed" : "slider should be available in game-pause",
		"lag" : "consider moving lasers into hitscan or a static object collection for reuse"
	}
	return gameFeel

################################################################################

func Design():
	var designIdeas : Dictionary = {
		"defenses" : "should planets have visible ships flying around them instead of a big number?",
		"pause drawing" : "should all the line-drawing features be available during pause?",
		"adjust lines?" : "if you can draw while paused, should you be able to redirect fleets in transit?",
		"multi-planet-select" : "should you be able to send ships from multiple planets at once? maybe the 'brush' gets bigger when you zoom out?",
		"planet production specialties" : "consider having military, cultural and economic planets: econ could buy upgrades, cultural can claim territory, military can defend those.",
	}
	return designIdeas

################################################################################


func Hard_Design_Problems():
	var hardDesignProblems : Dictionary = {
		"special sauce" : "what makes this game more interesting than any other node-war / demolition derby style game?",
		"complexity vs simplicity" : "How do you add depth while keeping everything quick and breezy?",
		"ai look-ahead" : "figure out how to let the AI plan a few moves in advance",
	}

	return hardDesignProblems

################################################################################

func Engineering():
	var engineering : Dictionary = {
		"referee" : "referee should handle all win/loss decisions. Go through faction and level and make sure they don't attempt the same thing."
		
		
	}
	
	return engineering

################################################################################

func Maybe_Someday():
	var maybeSomeday : Dictionary = {
		"released fleets invisible to enemy":"- there's a big flaw in fleet engagement: once a fleet has been released from it's path, it no longer has a dogfightzone collision area, so other ships can't engage it.",
		"multiplayer":"Will you add multiplayer support? global.PlayerFactionObj may fail",
		"Mods?" : "if you want it to be moddable, sprites and faction / ship properties should be loaded from files",
		"Mod reference" : "https://docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_pcks.html#overview-of-pck-files",
		"Diegetic menus" : "Why are menus buttons? You could have users draw a path for a spaceship into a portal",
	}
	
	return maybeSomeday

################################################################################

func References():
	pass
	
"""
Other awesome godot project management tools:
	https://github.com/godotengine/awesome-godot#projects

Node Conquest games:
- Galcon
- Dominari Empires
- Eufloria
- Ghost in the Cell on codingame.com
- R.O.O.T.S.
- many newgrounds games: Phage Wars/Tentacle Wars/Civilization Wars/Virus Wars
- FreeOrion
- Auralux


TBS Games with bases
- hex empire
- master of magic
- master of orion

Line-Drawing games
- flight control, etc.

"""

