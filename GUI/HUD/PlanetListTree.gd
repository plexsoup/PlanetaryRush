extends Tree


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
#	if global.Ticks % 200 == 0:
#		populateTree()

func populateTree():
	printerr("PlanetListTree.gd populateTree is no longer required.")
	return
	
	var level = global.Main.CurrentLevel
	var tree = self
	tree.clear()
	var root = tree.create_item()
	tree.set_hide_root(true)
	var numTotalPlanets:int = 0
	for factionObj in global.Main.CurrentLevel.FactionContainer.get_children():
		var factionNode = tree.create_item(root)
		var factionName = factionObj.name
		factionNode.set_text(0, "Faction: " + factionName)
		var numFactionPlanets : int = 0
		for planet in factionObj.CurrentPlanetList:
			var planetNode = tree.create_item(factionNode)
			planetNode.set_text(0, planet.name)
			numTotalPlanets += 1
			numFactionPlanets += 1
		var factionSummaryNode = tree.create_item(factionNode)
		factionSummaryNode.set_text(0, "Total " + factionObj.name + " == " + str(numFactionPlanets))
	var summaryNode = tree.create_item(root)
	summaryNode.set_text(0, "Summary")
	var planetContainerNode = tree.create_item(summaryNode)
	
	planetContainerNode.set_text(0, "Planets: " + str(global.planet_container.get_child_count()) )
	var countNode = tree.create_item(summaryNode)
	countNode.set_text(0, "Faction count = " + str(numTotalPlanets))
	
