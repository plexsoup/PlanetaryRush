extends Tree


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.Ticks % 200 == 0:
		populateTree()

func populateTree():
	var tree = self
	tree.clear()
	var root = tree.create_item()
	tree.set_hide_root(true)
	for factionObj in global.Main.CurrentLevel.FactionContainer.get_children():
		var factionNode = tree.create_item(root)
		var factionName = str(factionObj.Number)
		if factionObj.IsLocalHumanPlayer:
			factionName = "Player 1"
		elif factionObj.IsNeutralFaction:
			factionName = "Neutral"
		factionNode.set_text(0, "Faction: " + factionName)
		for planet in factionObj.CurrentPlanetList:
			var planetNode = tree.create_item(factionNode)
			planetNode.set_text(0, planet.name)
			

